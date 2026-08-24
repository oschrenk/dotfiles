#!/usr/bin/env bash
# Backfill GTQ-per-EUR daily history into Prometheus on pi-2.
#
# Currency has one value per day, so this writes one sample per day and nothing
# denser. That makes the series sparse relative to Prometheus' 5-minute lookback,
# which means queries MUST wrap it:
#
#     last_over_time(fx_rate{base="EUR",quote="GTQ"}[36h])
#
# A bare `fx_rate` returns empty for all but 5 minutes of each day, in range
# queries as well as instant ones. 36h rather than 24h covers weekends and
# holidays. Padding the data to scrape interval instead would be working around a
# query-layer problem in the storage layer, and costs ~290x the samples.
#
# The generator runs here, not on the pi: pi-2 has no python3, and this keeps the
# SOAP parsing and both network calls off the box that has to stay up.
set -euo pipefail

DAYS="${1:-90}"
HOST="${FX_HOST:-oliver@pi-2.local}"
RETENTION_DAYS=90   # keep in step with services.prometheus.retentionTime

command -v python3 >/dev/null || { echo "ERROR: python3 not on PATH (homebrew python)." >&2; exit 1; }

if [ "$DAYS" -gt "$RETENTION_DAYS" ]; then
  echo "WARNING: asking for ${DAYS}d but Prometheus retention is ${RETENTION_DAYS}d." >&2
  echo "         Blocks entirely older than retention are deleted on the next" >&2
  echo "         compaction, so the excess is written and then swept within hours." >&2
  echo "         Raise services.prometheus.retentionTime first if you want to keep it." >&2
fi

OM=$(mktemp -t fx-gtq-eur.XXXXXX)
trap 'rm -f "$OM"' EXIT

python3 - "$OM" "$DAYS" <<'PY'
import urllib.request, json, re, datetime, sys

path, days = sys.argv[1], int(sys.argv[2])
UA = {"User-Agent": "curl/8.7 (homelab fx backfill)"}   # frankfurter 403s urllib's default
today = datetime.datetime.now(datetime.timezone.utc).date()
start = today - datetime.timedelta(days=days)

def get(url, data=None, headers=None):
    h = dict(UA); h.update(headers or {})
    return urllib.request.urlopen(urllib.request.Request(url, data=data, headers=h), timeout=60).read().decode()

# Banco de Guatemala, GTQ per USD. SOAP POST only — the HTTP GET binding is
# disabled and answers every method with an ASP.NET runtime error page. dd/mm/yyyy.
env = ('<?xml version="1.0" encoding="utf-8"?>'
       '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body>'
       '<TipoCambioRango xmlns="http://www.banguat.gob.gt/variables/ws/">'
       f'<fechainit>{start.strftime("%d/%m/%Y")}</fechainit>'
       f'<fechafin>{today.strftime("%d/%m/%Y")}</fechafin>'
       '</TipoCambioRango></soap:Body></soap:Envelope>')
xml = get("https://www.banguat.gob.gt/variables/ws/TipoCambio.asmx",
          env.encode(), {"Content-Type": "text/xml; charset=utf-8"})
gtq_usd = {}
for m in re.finditer(r"<fecha>(\d{2})/(\d{2})/(\d{4})</fecha>\s*<(?:referencia|venta)>([\d.]+)<", xml):
    d, mo, y, v = m.groups()
    gtq_usd[datetime.date(int(y), int(mo), int(d))] = float(v)
if not gtq_usd:
    sys.exit("ERROR: Banguat returned no rows — check the SOAP response shape.")

# ECB via Frankfurter, EUR per USD. Business days only.
fx = json.loads(get(f"https://api.frankfurter.dev/v1/{start}..{today}?base=USD&symbols=EUR"))["rates"]
eur_usd = {datetime.date.fromisoformat(k): v["EUR"] for k, v in fx.items()}
if not eur_usd:
    sys.exit("ERROR: Frankfurter returned no rates.")

# Forward-fill each source independently — neither publishes at weekends, and
# Guatemalan and TARGET holidays are different days.
rows, lg, le = [], None, None
for i in range(days + 1):
    day = start + datetime.timedelta(days=i)
    lg = gtq_usd.get(day, lg); le = eur_usd.get(day, le)
    if lg is not None and le is not None:
        rows.append((day, lg / le))     # (GTQ per USD) / (EUR per USD) = GTQ per EUR

# Noon UTC: a date carries no time of day, and midday keeps each point inside the
# day it belongs to whatever timezone the dashboard is read in.
out = ["# TYPE fx_rate gauge",
       "# HELP fx_rate Units of quote currency per one unit of base currency"]
for day, rate in rows:
    ts = int(datetime.datetime.combine(day, datetime.time(12, 0), tzinfo=datetime.timezone.utc).timestamp())
    out.append('fx_rate{base="EUR",quote="GTQ"} %.6f %d' % (rate, ts))
out.append("# EOF")
open(path, "w").write("\n".join(out) + "\n")

vals = [r[1] for r in rows]
print(f"banguat {len(gtq_usd)} rows, ecb {len(eur_usd)} rows -> {len(rows)} daily samples")
print(f"{rows[0][0]} .. {rows[-1][0]}   min {min(vals):.4f}  max {max(vals):.4f}  last {vals[-1]:.4f}")
PY

echo "copying to ${HOST} ..."
scp -q "$OM" "${HOST}:/tmp/fx-gtq-eur.om"

ssh "$HOST" 'sudo bash -s' <<'REMOTE'
set -euo pipefail
DATA=/var/lib/prometheus2/data
WORK=$(mktemp -d /var/lib/prometheus2/fxbackfill.XXXXXX)
trap 'rm -rf "$WORK" /tmp/fx-gtq-eur.om' EXIT

# Capped for the same reason as prometheus-cost-backfill: an unbounded promtool
# starves userspace on a 3.7G Pi with no swap, and takes sshd down with it.
systemd-run --scope --quiet -p MemoryMax=1G -p MemorySwapMax=0 \
  promtool tsdb create-blocks-from openmetrics -q /tmp/fx-gtq-eur.om "$WORK"

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
echo "  last_over_time(fx_rate{base=\"EUR\",quote=\"GTQ\"}[36h])"
