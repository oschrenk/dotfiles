#!/bin/bash
# PreToolUse hook for AskUserQuestion.
# Denies the dialog when the same turn already has longer assistant text: Claude Code does not show
# text written before an AskUserQuestion call in the same turn, so the user never sees it.
# Known open bug: https://github.com/anthropics/claude-code/issues/75182 (earlier #65662, closed).
set -euo pipefail

# a short lead-in such as "Two options:" is harmless; an explanation is not
MAX_TEXT_BEFORE_QUESTION=200

input=$(cat)
transcript=$(jq -r '.transcript_path // empty' <<<"$input")
[[ -n "$transcript" && -f "$transcript" ]] || exit 0

# assistant text since the last entry that is not a tool result (a user message, a peer message, a notice)
length=$(jq -s '
  def turn_start: .type == "user"
    and ((.message.content | type) == "string" or (.message.content | any(.type != "tool_result")));
  (to_entries | map(select(.value | turn_start) | .key) | max // -1) as $start
  | .[$start + 1:]
  | map(select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text | length)
  | add // 0' "$transcript" 2>/dev/null || echo 0)

(( length > MAX_TEXT_BEFORE_QUESTION )) || exit 0

jq -n --arg n "$length" '{hookSpecificOutput: {
  hookEventName: "PreToolUse",
  permissionDecision: "deny",
  permissionDecisionReason: ("This turn already has " + $n + " characters of text, and the AskUserQuestion dialog hides it from the user (Claude Code bug). End the turn now with that text and a plain question. Open a dialog only in a turn with no longer text before it.")
}}'
