#!/bin/sh

# all other projects
session_raw=$(tmux list-sessions -F '#{session_name}:#{session_path}' -f "#{==:#{session_attached},1}")
session_name=$(echo "$session_raw" | cut -d ":" -f 1)
session_path=$(echo "$session_raw" | cut -d ":" -f 2)

# don't draw anything for default session
if [ "$session_name" = "default" ]; then
  sketchybar --set "$NAME" drawing=off 
  exit 0
fi

# shorten the branch name to before slash
# usually this this is the ticket number
# also convert to lower case
branch=$(git -C "$session_path" rev-parse --abbrev-ref HEAD | cut -d '/' -f 1 | tr '[:upper:]' '[:lower:]')

sketchybar --set "$NAME" drawing=on icon.drawing=on icon=⎇  label="$branch"
