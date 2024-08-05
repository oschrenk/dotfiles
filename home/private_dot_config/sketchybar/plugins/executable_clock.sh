#!/bin/sh

TZ="$1"
case "$TZ" in
   "America/Guatemala") 
     ICON="🇬🇹"
     ICON_DRAWING="on"
     TIME="$(TZ=${TZ} date '+%a %d %b %H:%M')"
   ;;
   "Asia/Ho_Chi_Minh") 
     ICON="🇻🇳"
     ICON_DRAWING="on"
     TIME="$(TZ=${TZ} date '+%a %d %b %H:%M')"
   ;;

   *) 
     # sf-synbol:clock
     ICON="􀐫"
     ICON_DRAWING="on"
     TIME="$(date '+%a %d %b %H:%M')" 
   ;;
esac

sketchybar --set "$NAME" \
                 icon="$ICON" \
                 icon.drawing="$ICON_DRAWING" \
                 label="${TIME}"

