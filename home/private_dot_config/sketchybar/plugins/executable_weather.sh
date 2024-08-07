#!/usr/bin/env sh

if [[ "$SENDER" = "mouse.clicked" ]]; then
  open -b "com.apple.weather"
fi

# if the service is overloaded, location resolution doesn't work, you will
# get an error message like
# `Unknown location; please try ~66.12345,5.123456`
# You can specify a geo location (even gps) but then the weather report is wrong
# so we keep the location, but ignore errors like that later
LOCATION="Haarlem,NL"
# see https://github.com/chubin/wttr.in/tree/master?tab=readme-ov-file#one-line-output
#%c is the weather as symbol
#%t is the temperature
FORMAT_STRING="+%x:+%t"
#?m forces metrics units
WEATHER_STRING=$(curl -s "https://wttr.in/${LOCATION}?m&format=${FORMAT_STRING}")

# the call can fail for various reasons
# - no network => empty string
# - 503: wttr can't request data from data provider
#        in that case the body contains 
#        `Sorry, we are running out of queries to the weather service at the moment.`
# - 200: but the body might contain one of these
#   1. `Unknown location; please try ~66.12345,5.123456`
#   2. `This query is already being processed`
#
# Re 2) See also https://github.com/chubin/wttr.in/blob/master/internal/processor/processor.go#L208
#
# It is not enough to inspect the return code, but also the body
if [[ -z "${WEATHER_STRING}" || "$WEATHER_STRING" == *"Sorry"* || "$WEATHER_STRING" == *"Unknown"* || "$WEATHER_STRING" == *"already being"* ]]; then
  sketchybar --set "$NAME" \
               icon="☄️" \
               icon.width="21" \
               icon.y_offset=1 \
               icon.padding_right=0 \
               label.padding_left=0 \
               label.drawing="off"
  exit 0
fi

WEATHER_ICON=$(echo "$WEATHER_STRING" | cut -d ':' -f 1 | xargs)
WEATHER_TEMP=$(echo "$WEATHER_STRING" | cut -d ':' -f 2 | tr -d '+')

# SF-SYMBOLS
CLOUD="􀇂"
CLOUD_BOLT="􀇒"
CLOUD_BOLT_RAIN="􀇞"
CLOUD_DRIZZLE="􀇄"
CLOUD_FILL="􀇃"
CLOUD_FOG="􀇊"
CLOUD_HEAVYRAIN="􀇈"
CLOUD_RAIN="􀇆"
CLOUD_RAINBOW_HALF="􁷞"
CLOUD_SLEET="􀇐"
CLOUD_SNOW="􀇎"
CLOUD_SUN="􀇔"
CLOUD_SUN_RAIN="􀇖"
SLEET="􀇐"
SNOWFLAKE="􀇥"
SUN_MAX="􀆭"

# WEATHER_SYMBOL_PLAIN
# see https://github.com/chubin/wttr.in/blob/master/lib/constants.py#L150C1-L170C2

case "$WEATHER_ICON" in
   # "?": "Unknown"
   '?')
     # put a rainbow instead of a question mark
     # unfortunately sf-symbols doesn't have a meteor glyph
     ICON="$RAINBOW"
   ;;
   # "o"   : "Sunny"
   'o')
     ICON="$SUN_MAX"
   ;;
   # "=": "Fog"
   '=')
     ICON="$CLOUD_FOG"
   ;;
   # "///": "HeavyRain"
   '///')
     ICON="$CLOUD_HEAVYRAIN"
   ;;
   # "//": "HeavyShowers"
   '//')
     ICON="$CLOUD_RAIN"
   ;;
   # "/": "LightRain"
   '/')
     ICON="$CLOUD_SUN_RAIN"
   ;;
   # ".": "LightShowers"
   '.')
     ICON="$CLOUD_DRIZZLE"
   ;;
   # "**": "HeavySnow"
   '**')
     ICON="$SNOWFLAKE"
   ;;
   # "*/*": "HeavySnowShowers"
   '*/*')
     ICON="$SNOWFLAKE"
   ;;
   # "*": "LightSnow"
   '*')
     ICON="$CLOUD_SNOW"
   ;;
   # "*/": "LightSnowShowers"
   '*/')
     ICON="$CLOUD_SNOW"
   ;;
   # "x": "LightSleet"
   'x')
     ICON="$SLEET"
   ;;
   # "x/": "LightSleetShowers"
   'x/')
     ICON="$CLOUD_SLEET"
   ;;
   # "m": "PartlyCloudy"
   'm')
     ICON="$CLOUD_SUN"
   ;;
   # "mm": "Cloudy"
   'mm')
     ICON="$CLOUD"
   ;;
   # "mmm": "VeryCloudy"
   'mmm')
     ICON="$CLOUD_FILL"
   ;;
   # "/!/": "ThunderyHeavyRain"
   '/!/')
     ICON="$CLOUD_BOLT"
   ;;
   # "!/": "ThunderyShowers"
   '!/')
     ICON="$CLOUD_BOLT_RAIN"
   ;;
   # "*!*": "ThunderySnowShowers"
   '*!*')
     ICON="$CLOUD_BOLT_RAIN"
   ;;
   # anything else
   "*") 
     # it means wttr.in added a new symbol
     ICON="x"
   ;;
esac

sketchybar --set "$NAME" \
           icon="$ICON" \
           icon.width="21" \
           icon.padding_right=0 \
           label.padding_left=0 \
           label="$WEATHER_TEMP"

