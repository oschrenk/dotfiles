#!/bin/sh

ICON_BATTERY_100=""
ICON_BATTERY_75=""
ICON_BATTERY_50=""
ICON_BATTERY_25=""
ICON_BATTERY_0=""
ICON_BATTERY_BOLT=""

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

case ${PERCENTAGE} in
  9[0-9]|100) ICON="$ICON_BATTERY_100"
  ;;
  [6-8][0-9]) ICON="$ICON_BATTERY_75"
  ;;
  [3-5][0-9]) ICON="$ICON_BATTERY_50"
  ;;
  [1-2][0-9]) ICON="$ICON_BATTERY_25"
  ;;
  *) ICON="$ICON_BATTERY_0"
esac

if [[ $CHARGING != "" ]]; then
  ICON="$ICON_BATTERY_BOLT"
fi

sketchybar --set "$NAME" \
             icon="$ICON" \
             label.drawing="off" 
