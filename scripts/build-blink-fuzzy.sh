#!/usr/bin/env zsh

trap 'echo exit; exit' INT TERM

set -e

PLUGIN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/blink.cmp"

if [ ! -d "$PLUGIN_DIR" ]; then
  echo "blink.cmp not installed at $PLUGIN_DIR; run :Lazy install first"
  exit 1
fi

# Rust is deliberately not on PATH (see config/nvim/README.md), so cargo comes
# from a throwaway nix shell rather than a permanent toolchain.
if ! command -v nix >/dev/null 2>&1; then
  echo "nix missing; cannot supply cargo"
  exit 1
fi

# Build inside a `nix develop` shell rather than `nix shell`. Two reasons the
# toolchain must come from nix and be entered this way:
#
#   1. Xcode 27 writes the __LINKEDIT string pool at a 4-byte offset while the
#      loader demands 8, so a dylib linked by Apple's toolchain builds fine and
#      then refuses to load. Every installed Xcode is on the 27 train, so there
#      is no stable Apple linker to fall back to. nix's ld64 links a dylib that
#      loads.
#   2. `nix shell` only puts binaries on PATH; it does not run the stdenv setup
#      hook that fills NIX_LDFLAGS with the libiconv search path. Rust links
#      against -liconv, so a `nix shell` build finds iconv only when the caller
#      already has those flags ambiently, which fish and `task` shells do not.
#      `nix develop` runs the hook, so the build is self-sufficient. mkShell
#      with libiconv in buildInputs is what populates the search path.
#
# Verified 2026-09-16 in a stripped env (env -i, no NIX_LDFLAGS, no SDKROOT):
# builds and the dylib loads, with no linker override needed.
NIXPKGS_REF="${NIXPKGS_REF:-github:NixOS/nixpkgs/nixpkgs-unstable}"

cd "$PLUGIN_DIR"
SHA="$(git rev-parse HEAD | cut -c1-7)"
echo "Building blink.cmp fuzzy matcher at $SHA with the nix toolchain"

# cargo does not refingerprint when the toolchain changes, so an artifact from
# a bad linker survives a rebuild verbatim. Clean first; the crate rebuilds in
# seconds.
nix develop --impure --expr \
  "let s = (builtins.getFlake \"$NIXPKGS_REF\").legacyPackages.\"$(nix eval --impure --raw --expr builtins.currentSystem)\"; in s.mkShell { packages = [ s.cargo s.rustc ]; buildInputs = [ s.libiconv ]; }" \
  --command sh -c "cargo clean --release && cargo build --release"

# blink.cmp loads lib/libblink_cmp_fuzzy.dylib.<sha>, so a build left under
# target/ is invisible to it. Older hashes are dead weight once the new one
# lands, and leaving them makes it hard to see which build is live.
#
# The (N) qualifier is load-bearing: zsh aborts the script on a glob that
# matches nothing, so a first run with an empty lib/ would fail here rather
# than skip the removal.
mkdir -p lib
rm -f lib/libblink_cmp_fuzzy.dylib.*(N)
mv target/release/libblink_cmp_fuzzy.dylib "lib/libblink_cmp_fuzzy.dylib.$SHA"

echo "Installed lib/libblink_cmp_fuzzy.dylib.$SHA"

# The dylib only proves itself by loading, which is the failure the Xcode beta
# linker causes, so ask neovim rather than trusting the build exit code.
AVAILABLE="$(nvim --headless "+lua io.write(tostring(require('blink.cmp').library_available()))" +qa 2>/dev/null)"
if [ "$AVAILABLE" = "true" ]; then
  echo "library_available() reports true"
else
  echo "library_available() reports $AVAILABLE; the dylib built but does not load"
  exit 1
fi
