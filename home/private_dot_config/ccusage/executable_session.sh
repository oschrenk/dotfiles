#!/bin/bash

session=$(tmux display-message -p '#S' 2>/dev/null)
if [[ "$session" == *timewax* ]]; then
  export CLAUDE_CONFIG_DIR=/Users/oliver/.config/claude/work
else
  export CLAUDE_CONFIG_DIR=/Users/oliver/.config/claude/personal
fi

ccusage daily --offline --since "$1" --json | jq .totals
