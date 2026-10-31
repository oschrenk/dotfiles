#!/bin/bash
# PreToolUse hook for Edit, Write, MultiEdit and Bash.
# Denies a comment prefixed with the ponytail skill's name, which that skill's text asks for.
set -euo pipefail

text=$(jq -r '.tool_input | [.new_string, .content, .command, (.edits[]?.new_string)] | map(values) | join("\n")')

if ! printf '%s' "$text" | grep -Eiq '(^|[[:space:]"'\''])(#|//|--|/\*|\*|<!--)[[:space:]]*ponytail:'; then
  exit 0
fi

jq -n '{hookSpecificOutput: {
  hookEventName: "PreToolUse",
  permissionDecision: "deny",
  permissionDecisionReason: "A comment must not carry a skill name as a prefix. This overrides the ponytail skill. State the limit as a plain comment, or drop the comment."
}}'
