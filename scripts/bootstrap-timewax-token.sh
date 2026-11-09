#!/usr/bin/env zsh

# Write the Timewax 1Password service account token to a file on this Mac and
# on the MaxBook. The work env files read it from there, so they hold only the
# path. Run it from the AirBook after every rotation: the headless MaxBook
# cannot answer the 1Password prompt, so it gets the token over ssh.

set -euo pipefail

TOKEN_ITEM="op://Personal/Service Accounts/timewax/credentials"
TOKEN_FILE=".config/op/timewax-service-account-token"
REMOTE_HOST="olivers-maxbook"

step() { echo; echo "==> $*"; }

TMP_TOKEN="$(mktemp)"
trap 'rm -f "$TMP_TOKEN"' EXIT

step "Reading $TOKEN_ITEM"
op read --no-newline "$TOKEN_ITEM" > "$TMP_TOKEN"
[[ -s "$TMP_TOKEN" ]] || { echo "ERROR: $TOKEN_ITEM is empty" >&2; exit 1; }

step "Writing ~/$TOKEN_FILE on $(hostname -s)"
install -d -m 0700 "$HOME/$(dirname "$TOKEN_FILE")"
install -m 0400 "$TMP_TOKEN" "$HOME/$TOKEN_FILE"

if [[ "$(hostname -s)" == "Olivers-MaxBook" ]]; then
  exit 0
fi

step "Writing ~/$TOKEN_FILE on $REMOTE_HOST"
# The remote login shell is fish, so the script runs under bash -c.
REMOTE_SCRIPT="set -e; umask 077; f=\"\$HOME/$TOKEN_FILE\"; mkdir -p \"\$(dirname \"\$f\")\"; t=\$(mktemp \"\$f.XXXXXX\"); cat > \"\$t\"; chmod 0400 \"\$t\"; mv -f \"\$t\" \"\$f\""
ssh -o ControlPath=none "$REMOTE_HOST" "bash -c '$REMOTE_SCRIPT'" < "$TMP_TOKEN"
