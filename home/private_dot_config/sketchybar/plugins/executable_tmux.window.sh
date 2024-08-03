#!/bin/sh

# Requirements
#  https://github.com/oschrenk/sessionizer
#  brew tap oschrenk/made
#  brew install sessionizer
#
# Process
# - "mother" script spawns a fixed number of this script
# - each "child" script has fixed id encoded in it's name
#     tmux.window.<N>
# - the index is from 0 to N
# - fetch the windows from tmux
# - assume a stable list of windows coming back
# - if window at given index exists, the index "points" to it
# - how we draw it depends on status of window
# - if there is only 1 window, don't draw

TMUX_WINDOW_INDEX=$(echo "$NAME" | cut -d '.' -f3)
TMUX_WINDOW_COUNT=$(/opt/homebrew/bin/sessionizer windows --json | jq length)
MAYBE_TMUX_WINDOW_ID=$(/opt/homebrew/bin/sessionizer windows --json | jq -r ".[${TMUX_WINDOW_INDEX}].id // empty")
ID_OF_ACTIVE_WINDOW=$(/opt/homebrew/bin/sessionizer windows --json | jq -r ".[] | select(.active==true) | .id")

# do NOT draw if:
# - can't find the window
# - there is only one window
if [[ -z "${MAYBE_TMUX_WINDOW_ID}" || $TMUX_WINDOW_COUNT -le '1' ]]; then
  sketchybar --set "$NAME" \
               drawing=off
else
  ICON_COLOR_ACTIVE="0xffcad3f5" 
  ICON_COLOR_INACTIVE="0xff484848"
  ICON_COLOR=$ICON_COLOR_INACTIVE

  # higlight current window
  if [ "$ID_OF_ACTIVE_WINDOW" == "$MAYBE_TMUX_WINDOW_ID" ]; then
    ICON_COLOR=$ICON_COLOR_ACTIVE
  fi

  sketchybar --set "$NAME" \
  	  		     icon.drawing=on \
               label.drawing="off" \
               drawing=on \
               icon.color="$ICON_COLOR" \
               icon="" 
fi

