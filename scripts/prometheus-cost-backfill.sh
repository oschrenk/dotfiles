#!/usr/bin/env bash
# Backfill the PoE cost recording rules over PoE history that predates them.
#
# Recording rules only produce samples from the moment they land, so a new cost
# series starts empty while the watts it is derived from go back to the start of
# retention. `promtool tsdb create-blocks-from rules` recomputes the rules against
# data already in the TSDB and writes real blocks, which closes that gap.
#
# Runs on pi-2 as root — see the prometheus-cost-backfill task, which pipes it over
# ssh. Takes the start time as its only argument, RFC3339 or a unix timestamp.
set -euo pipefail

START="${1:-}"
END="${2:-}"

DATA_DIR=/var/lib/prometheus2/data
PROM_URL=http://127.0.0.1:9090

command -v promtool >/dev/null || {
  echo "ERROR: promtool not on PATH. It ships in the 'cli' output of the prometheus" >&2
  echo "       package, added to systemPackages in modules/nixos/prometheus.nix." >&2
  echo "       Run 'task nix-rebuild-pi-2' first." >&2
  exit 1
}

# Prometheus must be up: create-blocks-from reads the source samples back out
# through the query API rather than off disk.
curl -sf "${PROM_URL}/-/healthy" >/dev/null || {
  echo "ERROR: Prometheus is not answering on ${PROM_URL}." >&2
  exit 1
}

# The rule file is generated into the nix store and referenced from the checked
# config, so both paths are derived from the running unit rather than guessed —
# a hardcoded store path goes stale on the next rebuild.
CONFIG=$(systemctl show prometheus -p ExecStart --value | grep -o -- '--config\.file=[^ ]*' | cut -d= -f2-)
[ -n "$CONFIG" ] || { echo "ERROR: could not read --config.file from the prometheus unit." >&2; exit 1; }

# The nixos module renders prometheus.yml as block YAML with unquoted store paths
# (`rule_files:` then `- /nix/store/...`), and `rule_files: []` when none are set —
# hence the block-sequence parse rather than looking for quoted strings.
mapfile -t RULE_FILES < <(awk '
  /^rule_files:/ { inblock = 1; next }
  inblock && /^-[[:space:]]+/ { sub(/^-[[:space:]]+/, ""); gsub(/^"|"$/, ""); print; next }
  inblock && /^[^[:space:]-]/ { inblock = 0 }
' "$CONFIG")
[ "${#RULE_FILES[@]}" -gt 0 ] || { echo "ERROR: no rule_files in $CONFIG — have the rules been deployed?" >&2; exit 1; }

# Derive the start from where the source metric actually begins, rather than from
# retention. This is not just tidier: promtool's rule importer walks every 2h window
# in the range and allocates per window whether or not it holds samples, so a 90-day
# range on a Pi is ~1080 block operations and enough memory pressure to take sshd
# down with it. Scoping to real data makes the cost proportional to the work.
if [ -z "$START" ]; then
  FIRST=$(curl -sg --data-urlencode \
    'query=min(min_over_time(timestamp(unpoller_device_port_poe_watts)[90d:1h]))' \
    -G "${PROM_URL}/api/v1/query" \
    | sed -n 's/.*"value":\[[0-9.]*,"\([0-9.]*\)"\].*/\1/p')

  [ -n "$FIRST" ] || {
    echo "ERROR: no unpoller_device_port_poe_watts history found — nothing to backfill." >&2
    echo "       Pass an explicit start if you meant to backfill a different metric." >&2
    exit 1
  }

  # A minute earlier, so the first real sample is inside the range rather than on
  # its boundary.
  START=$(printf '%.0f' "$FIRST")
  START=$((START - 60))
  echo "start:   derived from first sample at $(date -u -d "@$START" +%Y-%m-%dT%H:%M:%SZ)"
fi

echo "config:  $CONFIG"
echo "rules:   ${RULE_FILES[*]}"
echo "start:   $START${END:+  end: $END}"

# A wide range is the failure mode that hurts, so make it a deliberate act. Roughly
# a week of 2h windows is comfortable; beyond that, say so explicitly.
NOW=$(date -u +%s)
START_EPOCH=$(date -u -d "$START" +%s 2>/dev/null || echo "$START")
SPAN_DAYS=$(( (NOW - START_EPOCH) / 86400 ))
if [ "$SPAN_DAYS" -gt 14 ] && [ -z "${BACKFILL_FORCE:-}" ]; then
  echo "ERROR: requested span is ${SPAN_DAYS} days. promtool allocates per 2h window" >&2
  echo "       regardless of whether it holds samples, and a range this wide has" >&2
  echo "       exhausted memory on this host before. Re-run with BACKFILL_FORCE=1" >&2
  echo "       if that is genuinely what you want." >&2
  exit 1
fi

# Same filesystem as the data directory, so the move below is a rename rather than
# a copy — a half-copied block is a block Prometheus will try to load.
WORK=$(mktemp -d "${DATA_DIR%/data}/backfill.XXXXXX")
trap 'rm -rf "$WORK"' EXIT

# Run under a scope with a hard memory cap: without it, promtool growing unbounded
# takes sshd down with it and the host has to be power-cycled out of band — which is
# exactly what happened on 2026-08-24. With it, the cgroup kills promtool and this
# script reports a failure instead.
#
# 1G against pi-2's 3.7G total leaves the monitoring stack itself room to keep running.
# MemorySwapMax=0 is belt-and-braces: there is no swap configured today, and this keeps
# the cap meaningful if that ever changes.
systemd-run --scope --quiet -p MemoryMax=1G -p MemorySwapMax=0 \
  promtool tsdb create-blocks-from rules \
  --url "$PROM_URL" \
  --start "$START" \
  ${END:+--end "$END"} \
  --output-dir "$WORK" \
  "${RULE_FILES[@]}"

shopt -s nullglob
BLOCKS=("$WORK"/*/)
if [ "${#BLOCKS[@]}" -eq 0 ]; then
  echo "No blocks produced — the requested range holds no source samples. Nothing to do."
  exit 0
fi

echo "Produced ${#BLOCKS[@]} block(s); installing into $DATA_DIR"
mv "${BLOCKS[@]}" "$DATA_DIR/"
chown -R prometheus:prometheus "$DATA_DIR"

# Blocks are discovered at startup, not mid-run: without this the new series stay
# invisible until the next compaction happens to notice them.
systemctl restart prometheus
echo "Done. Prometheus restarted."
