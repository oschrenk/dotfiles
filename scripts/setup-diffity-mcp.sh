#!/bin/sh

# Registers the Diffity MCP server for both Claude profiles. Run once per Mac,
# after the app is installed. The app's Connect button reaches only one profile.
set -eu

app="/Applications/Diffity.app/Contents/MacOS"
socket="$HOME/Library/Application Support/com.diffity.app/mcp.sock"

json="{\"type\":\"stdio\",\"command\":\"$app/diffity-mcp\",\"args\":[\"--terminal\",\"--socket\",\"$socket\"]}"

for profile in personal work; do
  export CLAUDE_CONFIG_DIR="$HOME/.config/claude/$profile"
  claude mcp remove --scope user diffity >/dev/null 2>&1 || true
  claude mcp add-json --scope user diffity "$json"
done
