#!/usr/bin/env zsh

set -euo pipefail

step() { echo; echo "==> $*"; }

# Install Nix (Determinate Systems)
if ! command -v nix &>/dev/null; then
  step "Installing Nix (Determinate Systems)..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
else
  step "Nix already installed, skipping."
fi

# Ensure nix is on PATH in this session
if [[ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]]; then
  source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
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

echo
echo "Done. Next steps:"
echo
echo "  1. Run nix-darwin (installs chezmoi, git, git-lfs, age, fish via Homebrew):"
echo "     sudo nix run nix-darwin -- switch --flake <dotfiles>/nix#\$(hostname -s)"
echo
echo "  2. Set up git-lfs:"
echo "     git lfs install"
echo
echo "  3. Initialize chezmoi:"
echo "     chezmoi init oschrenk/dotfiles"
