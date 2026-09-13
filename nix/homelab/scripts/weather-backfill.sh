#!/usr/bin/env bash
# Backfill outside-weather history for Guatemala City Zona 14 into Prometheus on pi-2.
#
# Open-Meteo publishes hourly, but the live job scrapes every 5 minutes and
# Prometheus' lookback is 5 minutes, so hourly samples would draw as scattered
# dots rather than a line. This interpolates linearly between the hourly readings
# onto the 5-minute grid, so the imported history is shaped like the live series
# and the panels need no last_over_time wrapper.
#
# That means 11 of every 12 samples are computed, not observed. Temperature and
# humidity move smoothly enough over an hour that the error is small, but the
# stored series does not distinguish the two — read minute-scale detail in the
# backfilled range as drawing, not measurement.
#
# The generator runs here, not on the pi: pi-2 has no python3, and this keeps the
# network call off the box that has to stay up.
set -euo pipefail

DAYS="${1:-14}"
HOST="${WEATHER_HOST:-oliver@pi-2.local}"
RETENTION_DAYS=90   # keep in step with services.prometheus.retentionTime
MAX_PAST_DAYS=92    # Open-Meteo's own ceiling for past_days on the forecast endpoint

# Must match nix/modules/nixos/weather.nix exactly. Different coordinates would
# still be Zona 14 weather, but a different label value is a different series and
# the history would never join the live one.
LATITUDE=14.5836
LONGITUDE=-90.5137
LOCATION="Guatemala City Zona 14"

command -v python3 >/dev/null || { echo "ERROR: python3 not on PATH (homebrew python)." >&2; exit 1; }

if [ "$DAYS" -gt "$MAX_PAST_DAYS" ]; then
  echo "ERROR: Open-Meteo serves at most ${MAX_PAST_DAYS} past days; asked for ${DAYS}." >&2
  exit 1
fi

if [ "$DAYS" -gt "$RETENTION_DAYS" ]; then
  echo "WARNING: asking for ${DAYS}d but Prometheus retention is ${RETENTION_DAYS}d." >&2
  echo "         Blocks entirely older than retention are deleted on the next" >&2
  echo "         compaction, so the excess is written and then swept within hours." >&2
  echo "         Raise services.prometheus.retentionTime first if you want to keep it." >&2
fi

NOW=$(date -u +%s)

# Where the live series already starts. Everything from that moment on is
# measured at the scrape interval and must not be papered over with interpolated
# points — this is what makes the script safe to re-run, and safe to run again
# months from now without overwriting real observations with drawings.
#
# 1h step over retention is 2160 points, which pi-2 answers instantly. But a
# range query reports the step grid, not the samples: the first point returned is
# the first grid instant that resolved, which lands up to an hour *after* the
# first real scrape. Stepping back one hour puts the cutoff before it for certain.
# The seam loses up to an hour of backfill, which is invisible; getting it wrong
# the other way draws interpolated points over real observations.
echo "asking ${HOST} where the live series starts ..."
CUTOFF=$(ssh "$HOST" "curl -sfg 'http://127.0.0.1:9090/api/v1/query_range?query=weather_temperature_celsius&start=$((NOW - RETENTION_DAYS * 86400))&end=${NOW}&step=3600'" \
  | python3 -c '
import json, sys
r = json.load(sys.stdin)["data"]["result"]
print(int(r[0]["values"][0][0]) - 3600 if r else 0)
')

if [ "$CUTOFF" -eq 0 ]; then
  CUTOFF="$NOW"
  echo "no live samples yet — backfilling up to now"
else
  echo "live series starts $(date -u -r "$CUTOFF" '+%Y-%m-%d %H:%M UTC') — backfilling up to there"
fi

OM=$(mktemp -t weather-zona14.XXXXXX)
trap 'rm -f "$OM"' EXIT

python3 - "$OM" "$DAYS" "$CUTOFF" "$LATITUDE" "$LONGITUDE" "$LOCATION" <<'PY'
import urllib.request, json, datetime, sys

path, days, cutoff, lat, lon, location = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), *sys.argv[4:7]

STEP = 300   # the live scrape_interval in weather.nix

# forecast_days=1 because past_days alone stops at yesterday; today's hours are
# needed to reach the cutoff. timeformat=unixtime so nothing here parses dates.
url = ("https://api.open-meteo.com/v1/forecast"
       f"?latitude={lat}&longitude={lon}"
       "&hourly=temperature_2m,apparent_temperature,relative_humidity_2m"
       f"&past_days={days}&forecast_days=1"
       "&timeformat=unixtime&timezone=GMT")
h = json.loads(urllib.request.urlopen(url, timeout=60).read())["hourly"]

# (exported metric name, Open-Meteo hourly variable, HELP). Names and the label
# below must match modules/nixos/weather.nix exactly, or promtool writes series
# the live job never appends to.
SERIES = [
    ("weather_temperature_celsius", "temperature_2m",
     "Outside air temperature two metres above ground"),
    ("weather_apparent_temperature_celsius", "apparent_temperature",
     "Perceived temperature, combining humidity, wind and radiation"),
    ("weather_relative_humidity_percent", "relative_humidity_2m",
     "Outside relative humidity two metres above ground"),
]

out = []
counts = {}
for name, var, help_text in SERIES:
    # Drop hours the model has not filled in, and anything at or past the cutoff.
    pts = [(t, v) for t, v in zip(h["time"], h[var]) if v is not None and t < cutoff]
    if len(pts) < 2:
        sys.exit(f"ERROR: {var} returned {len(pts)} usable hours — nothing to interpolate.")

    # OpenMetrics wants one contiguous block per metric family, timestamps
    # ascending. Emitting family by family rather than timestamp by timestamp is
    # what keeps that true.
    out.append(f"# TYPE {name} gauge")
    out.append(f"# HELP {name} {help_text}")

    n = 0
    for (t0, v0), (t1, v1) in zip(pts, pts[1:]):
        span = t1 - t0
        # Walk [t0, t1) so the shared endpoint is written once, by the next pair.
        for ts in range(t0, t1, STEP):
            v = v0 + (v1 - v0) * (ts - t0) / span
            out.append('%s{location="%s"} %.3f %d' % (name, location, v, ts))
            n += 1
    # The final hourly reading itself, which the half-open walk above skips.
    out.append('%s{location="%s"} %.3f %d' % (name, location, pts[-1][1], pts[-1][0]))
    n += 1
    counts[name] = (n, pts[0][0], pts[-1][0], min(v for _, v in pts), max(v for _, v in pts))

out.append("# EOF")
open(path, "w").write("\n".join(out) + "\n")

fmt = lambda ts: datetime.datetime.fromtimestamp(ts, datetime.timezone.utc).strftime("%Y-%m-%d %H:%M")
for name, (n, first, last, lo, hi) in counts.items():
    print(f"{name}: {n} samples  {fmt(first)} .. {fmt(last)} UTC  min {lo:g}  max {hi:g}")
PY

echo "copying to ${HOST} ..."
scp -q "$OM" "${HOST}:/tmp/weather-zona14.om"

ssh "$HOST" 'sudo bash -s' <<'REMOTE'
set -euo pipefail
DATA=/var/lib/prometheus2/data
WORK=$(mktemp -d /var/lib/prometheus2/weatherbackfill.XXXXXX)
trap 'rm -rf "$WORK" /tmp/weather-zona14.om' EXIT

# Capped for the same reason as prometheus-cost-backfill and fx-backfill: an
# unbounded promtool starves userspace on a 3.7G Pi with no swap, and takes sshd
# down with it. promtool allocates per 2h window whether or not the window is
# dense, so the cost tracks the range asked for, not the sample count.
systemd-run --scope --quiet -p MemoryMax=1G -p MemorySwapMax=0 \
  promtool tsdb create-blocks-from openmetrics -q /tmp/weather-zona14.om "$WORK"

shopt -s nullglob
BLOCKS=("$WORK"/*/)
echo "blocks produced: ${#BLOCKS[@]}"
[ "${#BLOCKS[@]}" -gt 0 ] || { echo "ERROR: no blocks produced." >&2; exit 1; }

mv "${BLOCKS[@]}" "$DATA/"
chown -R prometheus:prometheus "$DATA"
# Blocks are discovered at startup, not mid-run.
systemctl restart prometheus
echo "prometheus restarted"
REMOTE

echo
echo "Verify with:"
echo "  weather_temperature_celsius"
echo "over a 7d range on the Homelab dashboard — no query wrapper needed."
