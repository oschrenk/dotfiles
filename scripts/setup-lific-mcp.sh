#!/bin/sh

# Registers the lific MCP server for both Claude profiles. Run once per Mac. The
# server address stays out of this public repo, so it comes in as an argument. The
# key is opnix's job, see nix/modules/darwin/secrets.nix.
set -eu

url="${1:?usage: task claude:lific -- https://<lific-host>}"

json="{\"type\":\"http\",\"url\":\"${url%/}/mcp\",\"headersHelper\":\"/run/current-system/sw/bin/lific-mcp-headers\"}"

for profile in personal work; do
  export CLAUDE_CONFIG_DIR="$HOME/.config/claude/$profile"
  claude mcp remove --scope user lific >/dev/null 2>&1 || true
  claude mcp add-json --scope user lific "$json"
done
