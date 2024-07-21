#!/usr/bin/env sh

# if the service is overloaded, location resolution doesn't work, you will
# get an error message like
# `Unknown location; please try ~66.12345,5.123456`
# You can specify a geo location (even gps) but then the weather report is wrong
# so we keep the location, but ignore errors like that later
LOCATION="Haarlem"
# see https://github.com/chubin/wttr.in/tree/master?tab=readme-ov-file#one-line-output
#%c is the weather as symbol
#%t is the temperature
FORMAT_STRING="+%c:+%t"
#?m forces metrics units
WEATHER_STRING=$(curl -s "https://wttr.in/${LOCATION}?m&format=${FORMAT_STRING}")

# the service can fail with a 503, if wttr can't request data from their data provider
# in that case the body contains 
# `Sorry, we are running out of queries to the weather service at the moment.`
# but it can also fail with a 200 
# 1. eg: `Unknown location; please try ~66.12345,5.123456`
# 2. `This query is already being processed`
#
# Re 2) See also https://github.com/chubin/wttr.in/blob/master/internal/processor/processor.go#L208
#
# It is not enough to inspect the return code, but also the body
if [[ "$WEATHER_STRING" == *"Sorry"* || "$WEATHER_STRING" == *"Unknown"* || "$WEATHER_STRING" == *"already being"* ]]; then
  FAILURE_ICON="☄️"
  sketchybar --set "$NAME" icon="$FAILURE_ICON" label="-"
  exit 0
fi

WEATHER_ICON=$(echo "$WEATHER_STRING" | cut -d ':' -f 1)
WEATHER_TEMP=$(echo "$WEATHER_STRING" | cut -d ':' -f 2 | tr -d '+')

sketchybar --set "$NAME" \
           icon="$WEATHER_ICON" \
           label="$WEATHER_TEMP"
