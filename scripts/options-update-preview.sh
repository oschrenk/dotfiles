#!/usr/bin/env bash
# Preview the option surface a flake input update would change: new/removed
# nix-darwin options, new/removed home-manager modules, and opnix options.
# Read-only: never writes flake.lock.
#
# The package and news halves of the preview live in `thaw` (thaw packages,
# thaw news), run by `task nix:update:preview` alongside this script.
#
# Usage:  scripts/options-update-preview.sh
set -euo pipefail

# Flake lives in ../nix relative to this script, so it works from any CWD.
FLAKE="${FLAKE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../nix" && pwd)}"
# Refs that `nix flake update` would move these inputs to (branch HEADs).
HM_REF="${HM_REF:-github:nix-community/home-manager}"
ND_REF="${ND_REF:-github:nix-darwin/nix-darwin/master}"
OPNIX_REF="${OPNIX_REF:-github:brizzbuzz/opnix}"

# Colour only when stdout is a terminal, and honour NO_COLOR (https://no-color.org),
# so piping into a file, a pager, or `task` stays free of escape sequences.
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  BOLD=$'\e[1m'; DIM=$'\e[2m'; RESET=$'\e[0m'
  RED=$'\e[31m'; GREEN=$'\e[32m'
else
  BOLD=''; DIM=''; RESET=''; RED=''; GREEN=''
fi

# "TITLE (n):" — title bold, count dim.
hdr() { printf '%s%s%s %s(%s)%s:\n' "$BOLD" "$1" "$RESET" "$DIM" "$2" "$RESET"; }
# Progress chatter goes to stderr so it never pollutes a redirected report.
note() { printf '%s→ %s%s\n' "$DIM" "$1" "$RESET" >&2; }

# ── option and module diffs ──────────────────────────────────────────────────
# nix-darwin and home-manager ship *modules*, so bumping them changes the
# option surface, not the version list thaw reports.
#
# Read straight from the source trees rather than evaluating them: fetch + grep
# costs seconds, an options eval costs minutes. jq comes from PATH (declared in
# nix/modules/darwin/brew/base.nix).

locked_rev() { # input name -> rev pinned in the current flake.lock
  nix flake metadata "$FLAKE" --json 2>/dev/null |
    jq -r --arg i "$1" '.locks.nodes[$i].locked.rev // empty'
}

src_of() { # flake ref -> store path of its fetched source tree
  nix flake prefetch --json "$1" 2>/dev/null | jq -r '.storePath // empty'
}

# nix-darwin declares each option at its full path on a single line:
#   system.defaults.loginwindow.HideUserAvatarAndName = mkOption {
# so the whole option set is recoverable from source text, no eval needed.
# Renames therefore read as one removal plus one addition, not as a rename.
darwin_options() { # source path -> sorted option paths
  grep -rhoE '^[[:space:]]*[a-zA-Z][A-Za-z0-9_."-]*[[:space:]]*=[[:space:]]*mk(Option|EnableOption)' \
    "$1/modules/" 2>/dev/null |
    sed -E 's/^[[:space:]]*//; s/[[:space:]]*=.*//' | sort -u
}

# home-manager nests its options inside attrsets, so the same trick yields
# fragments rather than paths. Module *files* are the reliable signal there:
# modules/programs/mblaze/default.nix appearing is how you learn mblaze exists.
# News entries live under the same tree but are dated notices, not modules.
hm_modules() { # source path -> sorted module file paths, excluding news
  (cd "$1" && find modules -name '*.nix' -not -path 'modules/misc/news/*' | sort)
}

# Sorted by filename, not path: home-manager sometimes files an entry under the
# previous month's directory, so path order is not date order.
# opnix declares its options nested inside submodules, so a full path is not
# recoverable from source text the way nix-darwin's is. The names still tell you
# a feature arrived: `polling` appearing is how you learn it exists.
opnix_version() { # source path -> version string, or "?" when absent
  grep -rhoE 'version = "[0-9][^"]*"' "$1" --include='*.nix' 2>/dev/null |
    head -1 | sed -E 's/.*"([^"]*)".*/\1/' | grep . || echo "?"
}

# A name alone does not say what an option is for, and opnix keeps a
# description beside each one. Print it, so a new option explains itself.
opnix_describe() { # args: source path, file of option names
  while IFS= read -r opt; do
    desc="$(awk -v o="$opt" '
      $0 ~ "^ *"o" = lib\\.mk(Option|EnableOption)" { f = 1 }
      f && /description = / { gsub(/^ *description = "|";$/, ""); print; f = 0 }
    ' "$1/nix/module.nix" | head -1)"
    printf '  %s+%s %s\n' "$GREEN" "$RESET" "$opt"
    [ -n "$desc" ] && printf '      %s%s%s\n' "$DIM" "$desc" "$RESET"
  done <"$2"
}

opnix_options() { # source path -> sorted option names
  grep -rhoE "[a-zA-Z][A-Za-z0-9]* = lib\.(mkOption|mkEnableOption)" "$1/nix/module.nix" 2>/dev/null |
    sed -E 's/ = lib\..*//' | sort -u
}

# Print "  <sigil> item" lines in a colour, or a dim "(none)" when empty.
list_or_none() { # args: file, colour, sigil
  if [ -s "$1" ]; then
    while IFS= read -r line; do printf '  %s%s%s %s\n' "$2" "$3" "$RESET" "$line"; done <"$1"
  else
    printf '  %s(none)%s\n' "$DIM" "$RESET"
  fi
}

count() { wc -l <"$1" | tr -d ' '; }

tmp2="$(mktemp -d)"; trap 'rm -rf "$tmp2"' EXIT

note "fetching nix-darwin + home-manager sources for option diff..."

nd_old_rev="$(locked_rev nix-darwin)"
hm_old_rev="$(locked_rev home-manager)"
nd_old="$(src_of "github:nix-darwin/nix-darwin/${nd_old_rev}")"
nd_new="$(src_of "$ND_REF")"
hm_old="$(src_of "github:nix-community/home-manager/${hm_old_rev}")"
hm_new="$(src_of "$HM_REF")"

echo
if [ "$nd_old" = "$nd_new" ]; then
  printf '%snix-darwin: already at %s HEAD (%s), no option changes%s\n' \
    "$DIM" "$ND_REF" "${nd_old_rev:0:7}" "$RESET"
else
  darwin_options "$nd_old" >"$tmp2/nd_old"
  darwin_options "$nd_new" >"$tmp2/nd_new"
  comm -13 "$tmp2/nd_old" "$tmp2/nd_new" >"$tmp2/nd_add"
  comm -23 "$tmp2/nd_old" "$tmp2/nd_new" >"$tmp2/nd_rem"
  hdr "NEW nix-darwin OPTIONS" "$(count "$tmp2/nd_add")"
  list_or_none "$tmp2/nd_add" "$GREEN" "+"
  echo
  hdr "REMOVED nix-darwin OPTIONS" "$(count "$tmp2/nd_rem")"
  list_or_none "$tmp2/nd_rem" "$RED" "-"
fi

echo
if [ "$hm_old" = "$hm_new" ]; then
  printf '%shome-manager: already at %s HEAD (%s), no module changes%s\n' \
    "$DIM" "$HM_REF" "${hm_old_rev:0:7}" "$RESET"
else
  hm_modules "$hm_old" >"$tmp2/hm_old"
  hm_modules "$hm_new" >"$tmp2/hm_new"
  comm -13 "$tmp2/hm_old" "$tmp2/hm_new" >"$tmp2/hm_add"
  comm -23 "$tmp2/hm_old" "$tmp2/hm_new" >"$tmp2/hm_rem"
  hdr "NEW home-manager MODULES" "$(count "$tmp2/hm_add")"
  list_or_none "$tmp2/hm_add" "$GREEN" "+"
  echo
  hdr "REMOVED home-manager MODULES" "$(count "$tmp2/hm_rem")"
  list_or_none "$tmp2/hm_rem" "$RED" "-"
fi

# ── opnix ────────────────────────────────────────────────────────────────────
# opnix ships one binary and a NixOS module, so a bump is invisible to the
# version diff above. Its options are the thing that changes: `polling` arriving
# in v0.11.0 is what makes a rotated secret reach a host without a rebuild.

note "fetching opnix sources for option diff..."

opnix_old_rev="$(locked_rev opnix)"
opnix_old="$(src_of "github:brizzbuzz/opnix/${opnix_old_rev}")"
opnix_new="$(src_of "$OPNIX_REF")"

echo
opnix_v_old="$(opnix_version "$opnix_old")"
opnix_v_new="$(opnix_version "$opnix_new")"

if [ "$opnix_old" = "$opnix_new" ]; then
  printf '%sopnix: already at %s HEAD (%s, v%s)%s\n' \
    "$DIM" "$OPNIX_REF" "${opnix_old_rev:0:7}" "$opnix_v_old" "$RESET"
else
  printf '%sopnix%s  %sv%s%s  →  %sv%s%s\n' \
    "$BOLD" "$RESET" "$DIM" "$opnix_v_old" "$RESET" "$GREEN" "$opnix_v_new" "$RESET"
  echo
  opnix_options "$opnix_old" >"$tmp2/op_old"
  opnix_options "$opnix_new" >"$tmp2/op_new"
  comm -13 "$tmp2/op_old" "$tmp2/op_new" >"$tmp2/op_add"
  comm -23 "$tmp2/op_old" "$tmp2/op_new" >"$tmp2/op_rem"
  hdr "NEW opnix OPTIONS" "$(count "$tmp2/op_add")"
  if [ -s "$tmp2/op_add" ]; then
    opnix_describe "$opnix_new" "$tmp2/op_add"
  else
    printf '  %s(none)%s\n' "$DIM" "$RESET"
  fi
  echo
  hdr "REMOVED opnix OPTIONS" "$(count "$tmp2/op_rem")"
  list_or_none "$tmp2/op_rem" "$RED" "-"
fi
