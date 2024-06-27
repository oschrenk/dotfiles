#!/bin/sh

if [ "$SENDER" = "nvim_gained_focus" ]; then
  case "$FILENAME" in
    # don't show when editing commit messages
    *COMMIT_EDITMSG*) ;;
    *)        sketchybar --set "$NAME" drawing=on icon= label="$FILENAME" ;;
  esac
  
fi

if [ "$SENDER" = "nvim_lost_focus" ]; then
  sketchybar --set "$NAME" drawing=off
fi
