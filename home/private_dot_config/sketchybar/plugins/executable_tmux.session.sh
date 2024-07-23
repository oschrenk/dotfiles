#!/bin/sh

session_name=$(tmux list-sessions -F '#{session_name}' -f "#{==:#{session_attached},1}")

if [ "$session_name" = "default" ]; then
  sketchybar --set "$NAME" \
               drawing=off 
else 
  sketchybar --set "$NAME" \
               drawing=on \
               icon.drawing=on \
               icon= label="$session_name"
fi
