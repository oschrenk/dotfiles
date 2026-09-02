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

# nix supplies cargo and rustc but never the linker, which comes from whatever
# xcode-select points at. The Xcode 27 beta linker writes __LINKEDIT at a
# 4-byte offset and the macOS 26/27 loader demands 8, so the build succeeds and
# the dylib then fails to load. Build against stable Xcode regardless of what
# is selected system-wide.
DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
if [ ! -d "$DEVELOPER_DIR" ]; then
  echo "stable Xcode missing at /Applications/Xcode.app"
  exit 1
fi
LINKER="$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"

# The linker override is keyed to the target triple, so the variable name
# changes with the architecture.
case "$(uname -m)" in
  arm64) LINKER_VAR="CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER" ;;
  x86_64) LINKER_VAR="CARGO_TARGET_X86_64_APPLE_DARWIN_LINKER" ;;
  *) echo "unsupported architecture: $(uname -m)"; exit 1 ;;
esac

cd "$PLUGIN_DIR"
SHA="$(git rev-parse HEAD | cut -c1-7)"
echo "Building blink.cmp fuzzy matcher at $SHA against Xcode $(/usr/bin/plutil -extract CFBundleShortVersionString raw /Applications/Xcode.app/Contents/Info.plist)"

nix shell nixpkgs#cargo nixpkgs#rustc --command \
  env DEVELOPER_DIR="$DEVELOPER_DIR" "$LINKER_VAR=$LINKER" \
  cargo build --release

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
