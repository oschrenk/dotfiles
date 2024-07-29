#!/usr/bin/env zsh

EVENT_NAME_LENGTH_MAX=40

# Benefits from
#
# Requirements
# brew install ical-buddy
# brew install coreutils
#
# https://github.com/oschrenk/mission
#   brew tap oschrenk/made
#   brew install mission
#
#  To watch for changes and subscribe to events
#   brew services start mission
#  Then allow
#   "System Settings" > "Privacy & Security" > "Full Disk Access", allow mission
#   brew services restart mission
#  This is because we are watching iCloud and system files (for macOS Focus)

# this script only work until midnight of a given day
# beyond that date and time calculation might be wrong

CURRENT_FOCUS=$(/opt/homebrew/bin/mission focus)

case "$CURRENT_FOCUS" in
  com.apple.donotdisturb.mode.default)
    sketchybar --set "$NAME" \
                 drawing=off
    return 0
    ;;
  com.apple.sleep.sleep-mode)
    sketchybar --set "$NAME" \
                 drawing=off
    return 0
    ;;
  *)
    # just continue
esac

EVENT_STRING=$(icalBuddy --excludeAllDayEvents --includeOnlyEventsFromNowOn --bullet "" --includeEventProps 'title, datetime' --timeFormat "%H:%M" --limitItems 2 --noCalendarNames -ps "|,|-|" eventsToday | grep -v "🕐 Timewax" | head -1)

# exit early if no event found for today
# for `//` see https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Shell-Parameter-Expansion
if [ -z "${EVENT_STRING//}" ]; then
  sketchybar --set "$NAME" \
    drawing=off
  exit
fi

EVENT_NAME=$(echo "$EVENT_STRING" | cut -d ',' -f 1)
EVENT_TIME=$(echo "$EVENT_STRING" | cut -d ',' -f 2)
EVENT_START_HOUR=$(echo "$EVENT_TIME" | cut -d '-' -f 1 | tr -d ' ')
EVENT_END_HOUR=$(echo "$EVENT_TIME" | cut -d '-' -f 2 | tr -d ' ')

TODAY_DATE=$(gdate '+%Y-%m-%d')
TIMEZONE=$(gdate '+%z')

EVENT_START_DATE="${TODAY_DATE}T${EVENT_START_HOUR}Z${TIMEZONE}"
EVENT_END_DATE="${TODAY_DATE}T${EVENT_END_HOUR}Z${TIMEZONE}"

EVENT_START_EPOCH=$(gdate --date="${EVENT_START_DATE}" +%s)
EVENT_END_EPOCH=$(gdate --date="${EVENT_END_DATE}" +%s)
NOW_EPOCH=$(gdate +%s)

EVENT_NAME_LENGTH=$(echo "${EVENT_NAME}" | wc -c | tr -d ' ')
# trim to max length
if [ $EVENT_NAME_LENGTH -ge $EVENT_NAME_LENGTH_MAX ]; then
  EVENT_NAME="$(echo $EVENT_NAME | cut -c 1-$EVENT_NAME_LENGTH_MAX)…"
fi

# if we are before the next event
if [ $NOW_EPOCH -lt $EVENT_START_EPOCH ]; then
  DIFFERENCE_IN_MINUTES=$((($EVENT_START_EPOCH - $NOW_EPOCH) / 60))

  # only show events within 60m
  if [ $DIFFERENCE_IN_MINUTES -lt 60 ]; then
    sketchybar --set "$NAME" \
      icon.drawing=off \
      drawing=on \
      label="$EVENT_NAME in ${DIFFERENCE_IN_MINUTES}m"
  else
    sketchybar --set "$NAME" \
                 drawing=off
  fi

# we are in the current event
else
  DIFFERENCE_IN_MINUTES=$((($EVENT_END_EPOCH - $NOW_EPOCH) / 60))
  sketchybar --set "$NAME" \
    icon.drawing=off \
    drawing=on \
    label="$EVENT_NAME, ${DIFFERENCE_IN_MINUTES}m left"
fi

