#!/usr/bin/env sh

LOCATION="Haarlem"
FORMAT_STRING="+%t%20+%c"

WEATHER_STRING=$(curl -s "https://wttr.in/${LOCATION}?format=${FORMAT_STRING}" | awk '{$1=$1};1')

# Fallback if empty
if [ -z $WEATHER_STRING ]; then
    sketchybar --set $NAME icon= label="-"
    return
fi

sketchybar --set $NAME icon= label="$WEATHER_STRING"
