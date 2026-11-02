#!/bin/bash
# PreToolUse hook for AskUserQuestion.
# Denies option previews. The terminal shows barely one line of a preview, so its content is unreadable.
set -euo pipefail

if ! jq -e '[.tool_input.questions[]?.options[]? | select((.preview // "") != "")] | length > 0' >/dev/null; then
  exit 0
fi

jq -n '{hookSpecificOutput: {
  hookEventName: "PreToolUse",
  permissionDecision: "deny",
  permissionDecisionReason: "Never set preview on AskUserQuestion options: the user sees barely one line of it. Put drafts, code and lists in plain text and end the turn with a plain question. Keep a dialog to short labels and descriptions."
}}'
