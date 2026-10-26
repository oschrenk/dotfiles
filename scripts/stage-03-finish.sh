#!/usr/bin/env zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${(%):-%N}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

step() { echo; echo "==> $*"; }

if [[ ! -x /run/current-system/sw/bin/darwin-rebuild ]]; then
  echo "Not ready: nix-darwin is not active. Run ./scripts/stage-02-switch.sh"
  exit 0
fi
export PATH="/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"

# A fresh clone holds LFS pointer files, so app icons and spell files stay broken
if [[ -e "$REPO_ROOT/.git/hooks/pre-push" ]]; then
  step "git-lfs hooks already installed, skipping."
else
  step "Installing git-lfs hooks"
  git -C "$REPO_ROOT" lfs install
fi
if git -C "$REPO_ROOT" lfs ls-files | grep -q ' - '; then
  step "Pulling LFS objects"
  git -C "$REPO_ROOT" lfs pull
else
  step "LFS objects already present, skipping."
fi

"$SCRIPT_DIR/bootstrap-infuse.sh"

echo
echo "Next: the app checklist in docs/first-run.md"
