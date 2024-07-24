#!/bin/sh

for window in $(tmux list-windows -F '#{window_name}' ); do
  sketchybar --set "$NAME.$ITER" \
               drawing=on \
               icon="$window" \
               icon.drawing="on" \
               label.drawing="off" \
               drawing="off"
done

