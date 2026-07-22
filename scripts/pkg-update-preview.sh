#!/usr/bin/env bash
# Preview which of MY declared packages would change if flake.lock were updated.
#
# Evaluates my declared package set (nix-darwin environment.systemPackages +
# home-manager home.packages) twice:
#   OLD = current flake.lock
#   NEW = with nixpkgs/home-manager overridden to their latest upstream
# then diffs package versions. Read-only: never writes flake.lock.
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

echo "→ evaluating current lock (host: ${HOST})..." >&2
eval_pkgs "$tmp/old.json"

echo "→ evaluating with updated nixpkgs + home-manager (fetches upstream, slower)..." >&2
eval_pkgs "$tmp/new.json" \
  --override-input nixpkgs "$NIXPKGS_REF" \
  --override-input home-manager "$HM_REF"

nix run nixpkgs#jq -- -rn \
  --slurpfile old "$tmp/old.json" --slurpfile new "$tmp/new.json" '
  ($old[0] | map({(.name): .version}) | add) as $o |
  ($new[0] | map({(.name): .version}) | add) as $n |
  ($o|keys) as $ok | ($n|keys) as $nk |
  ([ $ok[] | select($n[.] != null and $o[.] != $n[.]) | {name:., old:$o[.], new:$n[.]} ]) as $upd |
  ([ $nk[] | select($o[.]==null) | {name:., v:$n[.]} ]) as $add |
  ([ $ok[] | select($n[.]==null) | {name:., v:$o[.]} ]) as $rem |
  "UPDATED (\($upd|length)):",
  ( $upd[] | "  \(.name)  \(.old)  →  \(.new)" ),
  (if ($upd|length)==0 then "  (none)" else empty end),
  "",
  "ADDED (\($add|length)):",
  ( $add[] | "  \(.name)  \(.v)" ),
  (if ($add|length)==0 then "  (none)" else empty end),
  "",
  "REMOVED (\($rem|length)):",
  ( $rem[] | "  \(.name)  \(.v)" ),
  (if ($rem|length)==0 then "  (none)" else empty end),
  "",
  "unchanged: \(($ok | map(select($n[.]==$o[.])) | length)) of \($ok|length) declared packages"
  '
