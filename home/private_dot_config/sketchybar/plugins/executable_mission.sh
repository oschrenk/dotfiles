#!/bin/sh

# Requirements
#  https://github.com/oschrenk/mission
#  brew tap oschrenk/made
#  brew install mission
#
#  To watch for changes and subscribe to events
#   brew services start mission
#  Then allow
#   "System Settings" > "Privacy & Security" > "Full Disk Access", allow mission
#   brew services restart mission
#  This is because we are watching iCloud and system files (for macOS Focus)

TASKS=$(/opt/homebrew/bin/mission tasks --show-done=false --show-cancelled=false)
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
               icon=󰸞 \
               label="No tasks" \
               drawing=on
fi
