#!/bin/sh

TZ="$1"
case "$TZ" in
   "America/Guatemala") 
     ICON="🇬🇹"
     ICON_DRAWING="on"
     TIME="$(TZ=${TZ} date '+%a %d %b %H:%M')"
     PADDING_RIGHT=10
   ;;
   "Asia/Ho_Chi_Minh") 
     ICON="🇻🇳"
     ICON_DRAWING="on"
     TIME="$(TZ=${TZ} date '+%a %d %b %H:%M')"
     PADDING_RIGHT=10
   ;;

   *) 
     # sf-synbol:clock
     ICON="􀐫"
     ICON_DRAWING="on"
     TIME="$(date '+%a %d %b %H:%M')" 
     PADDING_RIGHT=3
   ;;
esac

sketchybar --set "$NAME" \
                 icon="$ICON" \
                 icon.drawing="$ICON_DRAWING" \
                 label="${TIME}" \
                 label.padding_right="$PADDING_RIGHT"

