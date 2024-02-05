#!/usr/bin/env sh

LOCATION="Haarlem"
# see https://github.com/chubin/wttr.in/tree/master?tab=readme-ov-file#one-line-output
#%c is the weather as symbol
#%t is the temperature
FORMAT_STRING="+%c:+%t"
#?m forces metrics units
WEATHER_STRING=$(curl -s "https://wttr.in/${LOCATION}?m&format=${FORMAT_STRING}")

WEATHER_ICON=$(echo $WEATHER_STRING | cut -d ':' -f 1)
WEATHER_TEMP=$(echo $WEATHER_STRING | cut -d ':' -f 2)

sketchybar --set $NAME icon="$WEATHER_ICON" label="$WEATHER_TEMP"
