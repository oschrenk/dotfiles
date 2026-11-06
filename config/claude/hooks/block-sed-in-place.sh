#!/bin/bash
# PreToolUse hook for Bash.
# Denies in-place sed. The sandbox's sed is GNU sed from nix, so BSD `-i ''`
# fails, and an in-place rewrite is not reviewable the way an Edit is.
set -euo pipefail

command=$(jq -r '.tool_input.command // empty')

# Heredoc bodies are data (file contents, messages), not commands; a "sed -i" in them must not trip the check.
code=$(printf '%s\n' "$command" | awk '
  !body && match($0, /<<-?[[:space:]]*["\047]?[A-Za-z_][A-Za-z0-9_]*["\047]?/) {
    tag = substr($0, RSTART, RLENGTH); sub(/^<<-?[[:space:]]*["\047]?/, "", tag); sub(/["\047]$/, "", tag)
    print; body = 1; next
  }
  body { line = $0; sub(/^[[:space:]]+/, "", line); if (line == tag) body = 0; next }
  { print }')

# sed only in command position: line start or after ; & | ( ` with optional sudo.
# Only flags before the script are checked, so `sed -e s/a/b/ -i f` slips through.
if ! printf '%s\n' "$code" | grep -Eq '(^|[;&|(`])[[:space:]]*(sudo[[:space:]]+)?g?sed([[:space:]]+-[a-zA-Z]+|[[:space:]]+--[a-z-]+(=[^[:space:]]*)?)*[[:space:]]+(-[a-zA-Z]*i|--in-place)'; then
  exit 0
fi

jq -n '{hookSpecificOutput: {
  hookEventName: "PreToolUse",
  permissionDecision: "deny",
  permissionDecisionReason: "sed -i is blocked. sed here is GNU sed from nix, not BSD sed. Change files with the Edit or Write tool; use sed only to read (sed -n)."
}}'
