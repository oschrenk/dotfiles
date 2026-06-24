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
echo "Done. Nix is installed but NOT on this shell's PATH yet."
echo
echo "IMPORTANT: before the first nix-darwin switch, grant Terminal Full Disk"
echo "Access. Without it, activation aborts writing com.apple.universalaccess and"
echo "leaves your login shell pointed at a fish that is not installed yet (dead"
echo "terminal). Fix:"
echo "  System Settings > Privacy & Security > Full Disk Access > enable Terminal,"
echo "  then quit Terminal (Cmd-Q) and reopen."
echo
echo "Get nix on PATH (a fresh terminal does this automatically, or run):"
echo
echo "     export PATH=\"/nix/var/nix/profiles/default/bin:\$PATH\""
echo
echo "Then, from the repo root (~/.local/share/chezmoi):"
echo
echo "  1. Run nix-darwin (installs chezmoi, git, git-lfs, fish via Homebrew):"
echo "     sudo nix run nix-darwin -- switch --flake ./nix#\$(hostname -s)"
echo
echo "  2. Set up git-lfs:"
echo "     git lfs install"
echo
echo "  3. Initialize chezmoi:"
echo "     chezmoi init oschrenk/dotfiles"
