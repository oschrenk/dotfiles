#!/usr/bin/env bash

# Drive the MaxBook's work VPN from this Mac, through the management socket of
# the openvpn-timewax daemon (nix/hosts/maxbook.nix).

set -euo pipefail

HOST="olivers-maxbook"
SOCKET="/var/run/openvpn-timewax.sock"
LOG="/var/log/openvpn-timewax.log"
# The server waits this long for the browser login after AUTH_PENDING.
AUTH_WINDOW_SECONDS=180
POLL_SECONDS=2
NC_IDLE_SECONDS=2

mgmt() {
  printf '%s\n' "$@" | ssh "$HOST" "/usr/bin/nc -w $NC_IDLE_SECONDS -U $SOCKET"
}

connect() {
  local start line url opened="" deadline
  # hold off, so openvpn's own reconnects do not stop and wait for a release.
  mgmt "hold off" "hold release" >/dev/null
  # From the current attempt's start, so a login URL that is already waiting is seen.
  start=$(ssh "$HOST" "grep -n -E 'process restarting|Need hold release' $LOG | tail -1 | cut -d: -f1")
  start=${start:-0}
  deadline=$((SECONDS + AUTH_WINDOW_SECONDS))
  while ((SECONDS < deadline)); do
    # "auth-failure (auth-token)" is a stale token that falls back to WEB_AUTH, not a failure.
    line=$(ssh "$HOST" "tail -n +$((start + 1)) $LOG | grep -E -o \"WEB_AUTH::[^']+|Initialization Sequence Completed|auth-failure\\]\" | tail -1") || true
    case "$line" in
      "Initialization Sequence Completed")
        echo "connected"
        return 0
        ;;
      "auth-failure]")
        echo "authentication failed" >&2
        return 1
        ;;
      WEB_AUTH::https://*)
        url="${line#WEB_AUTH::}"
        if [[ "$url" != "$opened" ]]; then
          echo "opening login: $url"
          open "$url"
          opened="$url"
        fi
        ;;
    esac
    sleep "$POLL_SECONDS"
  done
  echo "not connected after ${AUTH_WINDOW_SECONDS}s" >&2
  return 1
}

case "${1:-}" in
  connect) connect ;;
  disconnect) mgmt "hold on" "signal SIGHUP" ;;
  state)
    mgmt "state" "hold"
    ssh "$HOST" "route -n get git.timewax.com | grep interface"
    ;;
  *)
    echo "usage: $0 connect|disconnect|state" >&2
    exit 2
    ;;
esac
