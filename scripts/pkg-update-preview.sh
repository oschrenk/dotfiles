#!/usr/bin/env bash
# Preview which of MY declared packages would change if flake.lock were updated.
#
# Evaluates my declared package set (nix-darwin environment.systemPackages +
# home-manager home.packages) twice:
#   OLD = current flake.lock
#   NEW = with nixpkgs/home-manager overridden to their latest upstream
# then diffs package versions. Read-only: never writes flake.lock.
#
# Also diffs what a bump would change *besides* package versions: new/removed
# nix-darwin options, new/removed home-manager modules, and home-manager's own
# news entries. See the "non-package changes" section at the bottom.
#
# Usage:  scripts/pkg-update-preview.sh          # auto-detected host below
#         HOST=Olivers-AirBook scripts/pkg-update-preview.sh
set -euo pipefail

# Flake lives in ../nix relative to this script, so it works from any CWD.
FLAKE="${FLAKE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../nix" && pwd)}"
HOST="${HOST:-Olivers-MaxBook}"
USER_NAME="${USER_NAME:-oliver}"
# Refs that `nix flake update` would move these inputs to (branch HEADs).
NIXPKGS_REF="${NIXPKGS_REF:-github:NixOS/nixpkgs/nixpkgs-unstable}"
HM_REF="${HM_REF:-github:nix-community/home-manager}"
ND_REF="${ND_REF:-github:nix-darwin/nix-darwin/master}"

# Colour only when stdout is a terminal, and honour NO_COLOR (https://no-color.org),
# so piping into a file, a pager, or `task` stays free of escape sequences.
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  BOLD=$'\e[1m'; DIM=$'\e[2m'; RESET=$'\e[0m'
  RED=$'\e[31m'; GREEN=$'\e[32m'; YELLOW=$'\e[33m'; CYAN=$'\e[36m'
else
  BOLD=''; DIM=''; RESET=''; RED=''; GREEN=''; YELLOW=''; CYAN=''
fi

# "TITLE (n):" — title bold, count dim.
hdr() { printf '%s%s%s %s(%s)%s:\n' "$BOLD" "$1" "$RESET" "$DIM" "$2" "$RESET"; }
# Progress chatter goes to stderr so it never pollutes a redirected report.
note() { printf '%s→ %s%s\n' "$DIM" "$1" "$RESET" >&2; }

CFG="darwinConfigurations.${HOST}.config"
ATTRS=(
  "${CFG}.environment.systemPackages"
  "${CFG}.home-manager.users.${USER_NAME}.home.packages"
)

APPLY='ps: map (p: { name = p.pname or p.name or "?"; version = p.version or "?"; })
        (builtins.filter (p: (builtins.tryEval (p ? type && p.type == "derivation")).value or false) ps)'

# Evaluate all attr paths for a given lock state, merge into one dedup'd JSON
# array. Extra args (--override-input …) are forwarded to every eval.
eval_pkgs() { # args: output-file, extra nix flags...
  local out="$1"; shift
  local combined="[]" attr one
  for attr in "${ATTRS[@]}"; do
    one="$(nix eval "${FLAKE}#${attr}" --apply "$APPLY" --json "$@" 2>/dev/null)"
    combined="$(nix run nixpkgs#jq -- -cn --argjson a "$combined" --argjson b "$one" '$a + $b')"
  done
  nix run nixpkgs#jq -- -c 'unique_by(.name)' <<<"$combined" >"$out"
}

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

note "evaluating current lock (host: ${HOST})..."
eval_pkgs "$tmp/old.json"

# A middle pass with ONLY nixpkgs bumped. Diffing baseline → this → both tells
# us which input is actually responsible for each package change, so the report
# can name the input to update instead of leaving you to guess. Costs one extra
# eval; the alternative (one pass per input) costs one per input for no more
# information, since nix-darwin and home-manager both follow this same nixpkgs.
note "evaluating with updated nixpkgs only (for attribution)..."
eval_pkgs "$tmp/np.json" --override-input nixpkgs "$NIXPKGS_REF"

note "evaluating with updated nixpkgs + home-manager (fetches upstream, slower)..."
eval_pkgs "$tmp/new.json" \
  --override-input nixpkgs "$NIXPKGS_REF" \
  --override-input home-manager "$HM_REF"

# Colours are passed in as jq args rather than post-processed, so each field can
# carry its own (old version dim, new version green) instead of a whole line.
nix run nixpkgs#jq -- -rn \
  --slurpfile old "$tmp/old.json" --slurpfile new "$tmp/new.json" \
  --slurpfile np "$tmp/np.json" \
  --arg B "$BOLD" --arg D "$DIM" --arg R "$RESET" \
  --arg GR "$GREEN" --arg YL "$YELLOW" --arg RD "$RED" --arg CY "$CYAN" '
  ($old[0] | map({(.name): .version}) | add) as $o |
  ($new[0] | map({(.name): .version}) | add) as $n |
  ($np[0]  | map({(.name): .version}) | add) as $p |
  # A change already visible when only nixpkgs moved came from nixpkgs; a change
  # that appears only once home-manager also moves came from home-manager.
  def src($k): if $p[$k] != $o[$k] then "nixpkgs" else "home-manager" end;
  ($o|keys) as $ok | ($n|keys) as $nk |
  ([ $ok[] | select($n[.] != null and $o[.] != $n[.]) | {name:., old:$o[.], new:$n[.], src:src(.)} ]) as $upd |
  ([ $nk[] | select($o[.]==null) | {name:., v:$n[.], src:src(.)} ]) as $add |
  ([ $ok[] | select($n[.]==null) | {name:., v:$o[.], src:src(.)} ]) as $rem |
  (($upd + $add + $rem) | map(.src) | unique) as $inputs |
  "\($B)UPDATED\($R) \($D)(\($upd|length))\($R):",
  ( $upd[] | "  \($YL)~\($R) \(.name)  \($D)\(.old)\($R)  →  \($GR)\(.new)\($R)  \($CY)[\(.src)]\($R)" ),
  (if ($upd|length)==0 then "  \($D)(none)\($R)" else empty end),
  "",
  "\($B)ADDED\($R) \($D)(\($add|length))\($R):",
  ( $add[] | "  \($GR)+\($R) \(.name)  \($D)\(.v)\($R)  \($CY)[\(.src)]\($R)" ),
  (if ($add|length)==0 then "  \($D)(none)\($R)" else empty end),
  "",
  "\($B)REMOVED\($R) \($D)(\($rem|length))\($R):",
  ( $rem[] | "  \($RD)-\($R) \(.name)  \($D)\(.v)\($R)  \($CY)[\(.src)]\($R)" ),
  (if ($rem|length)==0 then "  \($D)(none)\($R)" else empty end),
  "",
  "\($D)unchanged: \(($ok | map(select($n[.]==$o[.])) | length)) of \($ok|length) declared packages\($R)",
  (if ($inputs|length) > 0
   then "\($B)to get these packages:\($R) \($GR)nix flake update \($inputs|join(" "))\($R)"
   else empty end)
  '

# ── non-package changes ──────────────────────────────────────────────────────
# Package versions are only half of what a bump delivers. nix-darwin and
# home-manager ship *modules*, so bumping them changes the option surface, not
# the version list — none of it shows up above. (Verified: overriding either one
# alone moves zero package versions, because both follow the same nixpkgs.)
#
# Read straight from the source trees rather than evaluating them: fetch + grep
# costs seconds, an options eval costs minutes. jq comes from PATH here (it is
# declared in nix/modules/darwin/brew/base.nix); the eval loop above resolves it
# through `nix run` instead, which is why these two differ.

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
hm_news_files() { # source path -> news entry paths, oldest first
  (cd "$1" && find modules/misc/news -name '*.nix' 2>/dev/null |
    awk -F/ '{print $NF"\t"$0}' | sort | cut -f2-)
}

news_message() { # news entry file -> its message body, de-indented
  sed -n "/message = ''/,/^[[:space:]]*'';/p" "$1" | sed '1d;$d' | sed -E 's/^[[:space:]]{4}//'
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

tmp2="$(mktemp -d)"; trap 'rm -rf "$tmp" "$tmp2"' EXIT

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

  # home-manager's own release notes for the span being previewed. These are the
  # breaking-change warnings that never appear in a version diff.
  hm_news_files "$hm_old" >"$tmp2/news_old"
  hm_news_files "$hm_new" >"$tmp2/news_new"
  comm -13 "$tmp2/news_old" "$tmp2/news_new" >"$tmp2/news_add"
  echo
  hdr "home-manager NEWS" "$(count "$tmp2/news_add")"
  if [ -s "$tmp2/news_add" ]; then
    while IFS= read -r entry; do
      # Entry date is the heading; the body is prose, so dim it to keep the
      # headings scannable when several entries stack up.
      printf '  %s── %s%s\n' "$CYAN" "${entry##*/}" "$RESET"
      while IFS= read -r line; do printf '  %s%s%s\n' "$DIM" "$line" "$RESET"; done \
        < <(news_message "$hm_new/$entry")
      echo
    done <"$tmp2/news_add"
  else
    printf '  %s(none)%s\n' "$DIM" "$RESET"
  fi
fi
