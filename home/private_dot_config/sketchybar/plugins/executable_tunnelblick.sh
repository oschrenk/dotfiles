#!/bin/sh

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

DEFAULT_ICON="􀞝"
ICON=$DEFAULT_ICON

# if any connection is connected
if [[ $STATE = "*"CONNECTED"*" ]]; then
  ICON="􀞛" 
fi

sketchybar --set "$NAME" \
               icon="$ICON" \
               label.drawing="off" 

