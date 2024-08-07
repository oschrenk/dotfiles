#!/bin/sh

if [[ "$SENDER" = "mouse.clicked" ]]; then
  open -b "md.obsidian"
fi

NEXT_TASK_LENGTH_MAX=35

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
  TASKS=$(/opt/homebrew/bin/mission tasks --journal=work --show-done=false --show-cancelled=false --json | jq -r .tasks[].text)

# default to "default" tasks, else
else
  TASKS=$(/opt/homebrew/bin/mission tasks --show-done=false --show-cancelled=false --json | jq -r .tasks[].text)
fi

case "$CURRENT_FOCUS" in
  com.apple.donotdisturb.mode.default)
    ICON="􀆺"
    ICON_COLOR="0xffcad3f5"
    LABEL_DRAWING="off"
    ;;
  com.apple.sleep.sleep-mode)
    ICON="􀙪"
    ICON_COLOR="0xffcad3f5"
    LABEL_DRAWING="off"
    ;;
  com.apple.focus.personal-time)
    ICON="􀉪"
    ICON_COLOR="0xffcad3f5"
    LABEL_DRAWING="on"
    ;;
  com.apple.focus.work)
    ICON="􁕝"
    ICON_COLOR="0xffcad3f5"
    LABEL_DRAWING="on"
    ;;
  *)
    ICON="􀟈"
    ICON_COLOR="0xff999999"
    LABEL_DRAWING="on"
    ;;
esac
  
NEXT_TASK=$(echo "$TASKS" | head -1)
DONE=$(/opt/homebrew/bin/mission tasks --show-done=false --show-cancelled=false --json | jq -r .summary.done)
TOTAL=$(/opt/homebrew/bin/mission tasks --show-done=false --show-cancelled=false --json | jq -r .summary.total)

NEXT_TASK_LENGTH=$(echo "${NEXT_TASK}" | wc -c | tr -d ' ')
# trim to max length
if [ "$NEXT_TASK_LENGTH" -ge "$NEXT_TASK_LENGTH_MAX" ]; then
  NEXT_TASK="$(echo "$NEXT_TASK" | cut -c 1-"$NEXT_TASK_LENGTH_MAX")…"
fi

if [[ "$DONE" != "$TOTAL" ]]; then
  sketchybar --set "$NAME" \
               icon="$ICON" \
               icon.color="$ICON_COLOR" \
               label="$NEXT_TASK" \
               label.drawing="$LABEL_DRAWING" \
               drawing=on
else
  sketchybar --set "$NAME" \
               icon="$ICON" \
               icon.color="$ICON_COLOR" \
               label="No tasks" \
               label.drawing="$LABEL_DRAWING" \
               drawing=on
fi
