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

# nix supplies the linker too, not just cargo and rustc. Xcode 27 writes the
# __LINKEDIT string pool at a 4-byte offset and the loader demands 8, so a
# dylib linked by Apple's toolchain builds fine and then refuses to load —
# and with every installed Xcode on the 27 train there is no stable Apple
# linker left to point at. nix's ld64 is versioned independently of Apple's
# beta cycle, and a dylib it links loads. Verified 2026-09-16.

# The linker override is keyed to the target triple, so the variable name
# changes with the architecture.
case "$(uname -m)" in
  arm64) LINKER_VAR="CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER" ;;
  x86_64) LINKER_VAR="CARGO_TARGET_X86_64_APPLE_DARWIN_LINKER" ;;
  *) echo "unsupported architecture: $(uname -m)"; exit 1 ;;
esac

cd "$PLUGIN_DIR"
SHA="$(git rev-parse HEAD | cut -c1-7)"
echo "Building blink.cmp fuzzy matcher at $SHA with the nix toolchain"

# cargo does not refingerprint when the linker changes, so an artifact linked
# by a bad toolchain survives a rebuild verbatim. Clean first; the crate
# rebuilds in seconds.
nix shell nixpkgs#cargo nixpkgs#rustc nixpkgs#clang --command \
  sh -c "cargo clean --release && env $LINKER_VAR=clang cargo build --release"

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
