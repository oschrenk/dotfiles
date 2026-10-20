#!/bin/sh
# Flags comment-only lines added to tracked files, so Claude removes them
# before Oliver has to ask. Reads the git diff rather than the tool input,
# because in auto mode most edits arrive via Bash heredocs and sed.
set -u

dir=${CLAUDE_PROJECT_DIR:-$PWD}
cd "$dir" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

found=$(git diff -U0 --no-color 2>/dev/null | awk '
  /^\+\+\+ / { file = $2; sub(/^[a-z]\//, "", file); next }
  /^\+/ && !/^\+\+\+/ {
    line = substr($0, 2)
    if (line ~ /^[[:space:]]*(#|\/\/|--|\/\*|\*)([[:space:]]|$)/) print "  " file ": " line
  }' | head -25)

[ -z "$found" ] && exit 0

msg=$(printf 'Comment-only lines were added to tracked files:\n%s\n\nOliver does not want explanatory or justifying comments. Delete each one and ask what a reader actually lost; keep it only if he asked for it or it states something the next line cannot.' "$found")
printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":%s},"suppressOutput":true}\n' "$(printf '%s' "$msg" | jq -Rsa .)"
