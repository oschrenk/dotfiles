#!/bin/sh

# only accept tmux_session_update events 
if [ "$SENDER" != "tmux_session_update" ]; then
  exit 0
fi

# don't draw anything for default session
if [ "$session_name" = "default" ]; then
  sketchybar --set "$NAME" drawing=off 
  exit 0
else 

# all other projects
session_raw=$(tmux list-sessions -F '#{session_name}:#{session_path}' -f "#{==:#{session_attached},1}")
session_name=$(echo "$session_raw" | cut -d ":" -f 1)
session_path=$(echo "$session_raw" | cut -d ":" -f 2)

branch=$(git -C "$session_path" rev-parse --abbrev-ref HEAD)

sketchybar --set "$NAME" drawing=on icon.drawing=on icon=⎇  label="$branch"
