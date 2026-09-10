#!/bin/bash
# PreToolUse hook for Edit|Write|MultiEdit.
# Rewrites file_path to its real target, but only when that target sits in
# the infuse store. Everywhere else the symlink write-refusal stays active.
set -euo pipefail

input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')

if [ -z "$file_path" ] || [ ! -L "$file_path" ]; then
  exit 0
fi

resolved=$(readlink -f "$file_path")
case "$resolved" in
  "$HOME/.local/share/infuse/"*) ;;
  *) exit 0 ;;
esac

# updatedInput replaces the whole tool input, so return all fields with
# file_path swapped, not file_path alone.
printf '%s' "$input" | jq --arg p "$resolved" \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", updatedInput: (.tool_input + {file_path: $p})}}'
