#!/usr/bin/env zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${(%):-%N}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

step() { echo; echo "==> $*"; }

# Name the machine: nix-darwin picks the host configuration by `hostname -s`
if grep -q "\"$(hostname -s)\" = " "$REPO_ROOT/nix/flake.nix"; then
  step "Hostname $(hostname -s) has a host configuration, skipping."
else
  step "Hostname $(hostname -s) has no host configuration in nix/flake.nix."
  "$SCRIPT_DIR/hostname.sh"
fi

# Install Nix (Determinate Systems)
if ! command -v nix &>/dev/null; then
  step "Installing Nix (Determinate Systems)..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
else
  step "Nix already installed, skipping."
fi

# Install Homebrew
if ! command -v brew &>/dev/null; then
  step "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  step "Homebrew already installed, skipping."
fi
# ensure brew is on PATH in this session
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install 1Password: the first switch needs its SSH agent to fetch the private flake
if [[ ! -d /Applications/1Password.app ]]; then
  step "Installing 1Password..."
  brew install --cask 1password
else
  step "1Password already installed, skipping."
fi

# Install the 1Password CLI: stage 02 reads the opnix token with it
if ! command -v op &>/dev/null; then
  step "Installing the 1Password CLI..."
  brew install --cask 1password-cli
else
  step "1Password CLI already installed, skipping."
fi

echo
echo "Next: prepare 1Password and Full Disk Access (README step 4), then ./scripts/stage-02-switch.sh"
