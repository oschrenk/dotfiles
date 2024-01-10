#!/bin/sh

session_raw=$(tmux list-sessions -F '#{session_name}:#{session_path}' -f "#{==:#{session_attached},1}")
session_name=$(echo "$session_raw" | cut -d ":" -f 1)
session_path=$(echo "$session_raw" | cut -d ":" -f 2)

if [ "$SENDER" = "tmux_session_update" ]; then
  sketchybar --set "$NAME" label="$session_name"
fi
