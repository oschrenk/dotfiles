#!/bin/sh

# Requirements
#  https://github.com/oschrenk/sessionizer
#  brew tap oschrenk/made
#  brew install sessionizer
#
# Process
# The "mother" script spawns a fixed count of this script
# Each "child" script has a fixed id encpded in it's name
#   tmux.session.<N>
# The index is from 0 to N
# we fetch the sessions from tmux
# we assume a stable list of sessions coming back
# we try to if a session at the given index exists
# we do that with `jq -r .[X] // empty`
# that way we can determine if the fixed index corresponds to a session
#

# settings
ICON=""
ICON_COLOR_ACTIVE="0xffcad3f5" 
ICON_COLOR_INACTIVE="0xff484848"
ICON_COLOR=$ICON_COLOR_INACTIVE

# logic
TMUX_SESSION_INDEX=$(echo "$NAME" | cut -d '.' -f3)
TMUX_SESSION_COUNT=$(/opt/homebrew/bin/sessionizer sessions --json | jq length)

MAYBE_TMUX_SESSION_NAME=$(/opt/homebrew/bin/sessionizer sessions --json | jq -r ".[${TMUX_SESSION_INDEX}].name // empty" )
NAME_OF_ATTACHED_SESSION=$(/opt/homebrew/bin/sessionizer sessions --json | jq -r ".[] | select(.attached==true) | .name")

IS_ATTACHED="false"
if [[ "$NAME_OF_ATTACHED_SESSION" == "$MAYBE_TMUX_SESSION_NAME" ]]; then
  IS_ATTACHED="true"
fi

# do NOT draw if:
# - can't find the session
if [[ -z "${MAYBE_TMUX_SESSION_NAME}" ]]; then
  sketchybar --set "$NAME" \
               drawing=off 
else 
  LABEL_DRAWING="off"
  LABEL=""

  # higlight current session
  if [[ "$IS_ATTACHED" = "true" ]]; then
    ICON_COLOR=$ICON_COLOR_ACTIVE
    LABEL_DRAWING="on"
    LABEL="$MAYBE_TMUX_SESSION_NAME"
  fi
  sketchybar --set "$NAME" \
               drawing=on \
               icon.drawing=on \
               icon="$ICON" \
               icon.color="$ICON_COLOR" \
               label.drawing="$LABEL_DRAWING" \
               label="$LABEL"
fi
