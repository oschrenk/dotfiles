#!/bin/bash
# PreToolUse hook for Bash.
# Denies in-place sed. The sandbox's sed is GNU sed from nix, so BSD `-i ''`
# fails, and an in-place rewrite is not reviewable the way an Edit is.
set -euo pipefail

command=$(jq -r '.tool_input.command // empty')

# ponytail: only flags before the script are checked, so `sed -e s/a/b/ -i f` slips through.
if ! printf '%s' "$command" | grep -Eq '(^|[;&|(`[:space:]])g?sed([[:space:]]+-[a-zA-Z]+|[[:space:]]+--[a-z-]+(=[^[:space:]]*)?)*[[:space:]]+(-[a-zA-Z]*i|--in-place)'; then
  exit 0
fi

jq -n '{hookSpecificOutput: {
  hookEventName: "PreToolUse",
  permissionDecision: "deny",
  permissionDecisionReason: "sed -i is blocked. sed here is GNU sed from nix, not BSD sed. Change files with the Edit or Write tool; use sed only to read (sed -n)."
}}'
