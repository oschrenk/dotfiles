#!/usr/bin/env zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${(%):-%N}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

OP_AGENT_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
TOKEN_FILE="/etc/opnix-token"
TOKEN_ITEM="op://Personal/Service Accounts/opnix-dotfiles/credentials"

step() { echo; echo "==> $*"; }

# Exit 0: a machine part-way through setup is not broken, just not ready yet.
not_ready() {
  echo
  echo "Not ready: $1"
  echo
  echo "Then re-run: ./scripts/stage-02-switch.sh"
  exit 0
}

if [[ -x /run/current-system/sw/bin/darwin-rebuild ]]; then
  step "nix-darwin already active, skipping. Later runs: task nix:rebuild:darwin"
  exit 0
fi

if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
command -v nix &>/dev/null || not_ready "nix is missing. Run ./scripts/stage-01-install.sh"
command -v op &>/dev/null || not_ready "op is missing. Run ./scripts/stage-01-install.sh"

[[ -S "$OP_AGENT_SOCK" ]] ||
  not_ready "1Password SSH agent. Open 1Password, sign in, sync, then enable Settings > Developer > 'Use the SSH agent'."

if [[ -s "$TOKEN_FILE" ]]; then
  step "$TOKEN_FILE already present, skipping."
else
  step "Writing $TOKEN_FILE from 1Password"
  TMP_TOKEN="$(mktemp)"
  trap 'rm -f "$TMP_TOKEN"' EXIT
  if ! op read --no-newline "$TOKEN_ITEM" > "$TMP_TOKEN" || [[ ! -s "$TMP_TOKEN" ]]; then
    not_ready "op could not read $TOKEN_ITEM. Enable Settings > Developer > 'Integrate with 1Password CLI'."
  fi
  sudo install -m 0600 -o root -g wheel "$TMP_TOKEN" "$TOKEN_FILE"
fi

# Fetch the private flake as this user, through the agent, so the root switch
# finds it in the store. A fresh Mac has no ~/.ssh/config to point root at it.
step "Fetching flake inputs"
SSH_AUTH_SOCK="$OP_AGENT_SOCK" GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new" \
  nix flake archive "$REPO_ROOT/nix" >/dev/null

step "Running the first nix-darwin switch"
sudo nix run nix-darwin -- switch --flake "$REPO_ROOT/nix#$(hostname -s)"

echo
echo "Next: open a new terminal, then ./scripts/stage-03-finish.sh"
