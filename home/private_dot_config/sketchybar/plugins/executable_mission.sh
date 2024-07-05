#!/bin/sh

# Requirements
# https://github.com/oschrenk/mission
# brew tap oschrenk/made
# brew install mission

TASKS=$("$HOME"/Frameworks/go/bin/mission tasks --show-done=false --show-cancelled=false)
NEXT_TASK=$(echo "$TASKS" | head -1 | cut -d " " -f 2-)
SUMMARY=$(echo "$TASKS" | tail -1 | cut -d " " -f 1)
DONE=$(echo "$SUMMARY" | cut -d "/" -f 1)
TOTAL=$(echo "$SUMMARY" | cut -d "/" -f 2)

if [[ "$DONE" != "$TOTAL" ]]; then
  sketchybar --set "$NAME" \
               icon=󰸞 \
               label="$NEXT_TASK $SUMMARY" \
               drawing=on
else
  sketchybar --set "$NAME" \
               drawing=off
fi
