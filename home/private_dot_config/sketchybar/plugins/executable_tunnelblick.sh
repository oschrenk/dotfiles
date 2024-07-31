#!/bin/sh

ICON_COLOR_ACTIVE="0xffcad3f5" 
ICON_COLOR_INACTIVE="0xff484848"

# Configuration states
#   EXITING
#   AUTH
#   GET_CONFIG
#   CONNECTED

# Test if Tunnelblick is available on the system
if [ ! -d /Applications/Tunnelblick.app ]; then
  sketchybar --set "$NAME" \
               drawing="off" 
  exit 0
fi

# If multiple connections are available, state will be comma-separated, eg:
# CONNECTED, EXITING
STATE=$(osascript -e "tell application \"/Applications/Tunnelblick.app\"" -e "get state of configurations" -e "end tell")

# disconnected by default
DEFAULT_ICON="􀞝"
ICON=$DEFAULT_ICON
ICON_COLOR="$ICON_COLOR_INACTIVE"

# if any connection is connected
if [[ $STATE == *"CONNECTED"* ]]; then
  ICON="􀞛" 
  ICON_COLOR="$ICON_COLOR_ACTIVE"
fi

sketchybar --set "$NAME" \
               icon="$ICON" \
               icon.color="$ICON_COLOR" \
               label.drawing="off" 

