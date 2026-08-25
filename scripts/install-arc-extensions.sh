#!/usr/bin/env zsh

# Install the browser extensions listed in data/arc-extensions.txt into Arc.
#
# Not a nix activation script: `extension install` writes into a running Arc
# profile and relaunches the browser, which is imperative state nix does not own.
#
# Each install relaunches Arc, so this is a `task extensions` you run on purpose,
# not something that happens on every rebuild.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${(%):-%N}")" && pwd)"
EXTENSIONS_FILE="$SCRIPT_DIR/data/arc-extensions.txt"

if ! command -v extension >/dev/null 2>&1; then
  echo "extension CLI missing; skipping (brew install extension)"
  exit 0
fi

cut -d "#" -f1 "$EXTENSIONS_FILE" | while IFS= read -r line; do
  [[ -z "${line// }" ]] && continue
  name="${line%%=*}"
  id="${line#*=}"
  echo "Installing ${name//\"/}"
  extension install arc "$id"
done
