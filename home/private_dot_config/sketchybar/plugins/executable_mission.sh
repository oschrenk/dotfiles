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

CURRENT_FOCUS=$(/opt/homebrew/bin/mission focus)

# choose "work" tasks when in "work" mode
if [[ "$CURRENT_FOCUS" == "com.apple.focus.work" ]]; then
  TASKS=$(/opt/homebrew/bin/mission tasks --journal=work --show-done=false --show-cancelled=false)

# default to "default" tasks, else
else
  TASKS=$(/opt/homebrew/bin/mission tasks --show-done=false --show-cancelled=false)

fi

case "$CURRENT_FOCUS" in
  com.apple.donotdisturb.mode.default)
    ICON="􀆺"
    ICON_COLOR="0xFFFFFFFF"
    ;;
  com.apple.sleep.sleep-mode)
    ICON="􀙪"
    ICON_COLOR="0xFFFFFFFF"
    ;;
  com.apple.focus.personal-time)
    ICON="􀉪"
    ICON_COLOR="0xFFFFFFFF"
    ;;
  com.apple.focus.work)
    ICON="􁕝"
    ICON_COLOR="0xFFFFFFFF"
    ;;
  *)
    ICON="􀟈"
    ICON_COLOR="0xFF999999"
    ;;
esac
  
NEXT_TASK=$(echo "$TASKS" | head -1 | cut -d " " -f 2-)
SUMMARY=$(echo "$TASKS" | tail -1 | cut -d " " -f 1)
DONE=$(echo "$SUMMARY" | cut -d "/" -f 1)
TOTAL=$(echo "$SUMMARY" | cut -d "/" -f 2)

if [[ "$DONE" != "$TOTAL" ]]; then
  sketchybar --set "$NAME" \
               icon="$ICON" \
               icon.color="$ICON_COLOR" \
               label="$NEXT_TASK $SUMMARY" \
               drawing=on
else
  sketchybar --set "$NAME" \
               icon="$ICON" \
               icon.color="$ICON_COLOR" \
               label="No tasks" \
               drawing=on
fi
