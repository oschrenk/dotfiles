#!/bin/sh

# settings
ICON_COLOR_ACTIVE="0xffcad3f5" 
ICON_COLOR_INACTIVE="0xff484848"
ICON_COLOR=$ICON_COLOR_INACTIVE

# logic
TMUX_SESSION_INDEX=$(echo "$NAME" | cut -d '.' -f3)
TMUX_SESSION_COUNT=$(tmux list-sessions -F '#{session_id}' | wc -l | xargs)
MAYBE_TMUX_SESSION=$(tmux list-sessions -F '#{session_name}:#{session_attached}' | sed "${TMUX_SESSION_INDEX}q;d")
TMUX_SESSION_INDEX_OF_ATTACHED=$(tmux list-sessions -F '#{session_name}:#{session_attached}' | awk '/:1/{ print NR; exit }')
TMUX_INDEX_DISTANCE=$(expr "$TMUX_SESSION_INDEX_OF_ATTACHED" - "$TMUX_SESSION_INDEX" | tr -d '-')

TOO_FAR="false"
if [[ $TMUX_INDEX_DISTANCE -gt '1' ]]; then
  TOO_FAR="true"
fi
IN_RANGE="false"
if [[ $TMUX_INDEX_DISTANCE -eq '1' ]]; then
  IN_RANGE="true"
fi
IS_ATTACHED="false"
if [[ $TMUX_INDEX_DISTANCE -eq '0' ]]; then
  IS_ATTACHED="true"
fi

echo "BEFORE $TMUX_SESSION_INDEX $TMUX_INDEX_DISTANCE \"$MAYBE_TMUX_SESSION\" far:$TOO_FAR attached:$IS_ATTACHED" >> ~/Downloads/log.txt

# do NOT draw if:
# - can't find the session
# - too far away
if [[ -z "${MAYBE_TMUX_SESSION}" || "$TOO_FAR" = "true" ]]; then
  sketchybar --set "$NAME" \
               drawing=off 
else 
  ICON=""
  LABEL_DRAWING="off"
  LABEL=""

  # higlight current session
  if [[ "$IS_ATTACHED" = "true" ]]; then
    ICON_COLOR=$ICON_COLOR_ACTIVE
    ICON=""
    LABEL_DRAWING="on"
    LABEL=$(echo "$MAYBE_TMUX_SESSION" | cut -d ":" -f1)
  fi
  sketchybar --set "$NAME" \
               drawing=on \
               icon.drawing=on \
               icon="$ICON" \
               icon.color="$ICON_COLOR" \
               label.drawing="$LABEL_DRAWING" \
               label="$LABEL"
fi
