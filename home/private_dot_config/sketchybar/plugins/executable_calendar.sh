#!/usr/bin/env zsh

# Requirements
# brew install ical-buddy
# brew install coreutils

# this script only work until midnight of a given day
# beyond that date and time calculation might be wrong

EVENT_STRING=$(icalBuddy --excludeAllDayEvents --includeOnlyEventsFromNowOn --bullet "" --includeEventProps 'title, datetime' --timeFormat "%H:%M" --limitItems 1 --noCalendarNames -ps "|,|-|" eventsToday)

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
EVENT_NAME_LENGTH_MAX=40
# trim to max length
if [ $EVENT_NAME_LENGTH -ge $EVENT_NAME_LENGTH_MAX ]; then
  EVENT_NAME="$(echo $EVENT_NAME | cut -c 1-$EVENT_NAME_LENGTH_MAX)…"
fi

# if we are before the next event
if [ $NOW_EPOCH -lt $EVENT_START_EPOCH ]; then
  DIFFERENCE_IN_MINUTES=$((($EVENT_START_EPOCH - $NOW_EPOCH) / 60))
  sketchybar --set "$NAME" \
    icon.drawing=off \
    drawing=on \
    label="$EVENT_NAME in ${DIFFERENCE_IN_MINUTES}m"

# we are in the current event
else
  DIFFERENCE_IN_MINUTES=$((($EVENT_END_EPOCH - $NOW_EPOCH) / 60))
  sketchybar --set "$NAME" \
    icon.drawing=off \
    drawing=on \
    label="$EVENT_NAME, ${DIFFERENCE_IN_MINUTES}m left"
fi

