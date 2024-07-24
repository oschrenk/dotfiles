#!/bin/sh

TMUX_WINDOW_INDEX=$(echo "$NAME" | cut -d '.' -f3)

echo "IDX: $TMUX_WINDOW_INDEX" >> ~/Downloads/log.txt

TMUX_WINDOW_COUNT=$(tmux list-windows -F '#{window_id}' | wc -l | xargs)
MAYBE_TMUX_WINDOW=$(tmux list-windows -F '#{window_name}:#{window_active}' | sed "${TMUX_WINDOW_INDEX}q;d")

# do NOT draw if:
# - can't find the window
# - there is only one window
if [[ -z "${MAYBE_TMUX_WINDOW}" || $TMUX_WINDOW_COUNT -le '1' ]]; then
  sketchybar --set "$NAME" \
               drawing=off
else
  WINDOW_NAME=$(echo "$MAYBE_TMUX_WINDOW" | cut -d ":" -f1)
  WINDOW_ACTIVE_STATE=$(echo "$MAYBE_TMUX_WINDOW" | cut -d ":" -f2)

  ICON_COLOR_ACTIVE="0xffcad3f5" 
  ICON_COLOR_INACTIVE="0xff484848"
  ICON_COLOR=$ICON_COLOR_INACTIVE

  # higlight current window
  if [ "$WINDOW_ACTIVE_STATE" -eq "1" ]; then
    ICON_COLOR=$ICON_COLOR_ACTIVE
  fi

  sketchybar --set "$NAME" \
  	  		     icon.drawing=on \
               label.drawing="off" \
               drawing=on \
               icon.color="$ICON_COLOR" \
               icon="" 
fi

