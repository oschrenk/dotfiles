# ekctl Scripting Examples

Advanced automation patterns for ekctl 1.4.0.

For most filtering needs prefer the built-in flags (`--search`, `--availability`, `--format`, comma-separated `--calendar`) over `jq` — they're shorter and don't drift as new fields are added. `jq` is still the right tool when you're transforming data shape, joining with external sources, or doing arithmetic across events.

## Date generation

### Prefer the convenience subcommands

For "today", "tomorrow", and "next N events", use the dedicated subcommands rather than computing dates. They're local-timezone-aware and don't depend on the BSD-only `date -v+1d` flag (which breaks on Linux containers):

```bash
ekctl today --calendar work          # events occurring today (local)
ekctl tomorrow --calendar work       # events occurring tomorrow
ekctl next --calendar work           # the next event
ekctl next --calendar work --count 5 # the next 5 events (default 90-day lookahead)
ekctl next --calendar work --days 7  # only look 7 days ahead
```

### When you need an explicit ISO 8601 timestamp

```bash
# Right now (UTC)
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Specific local time today (macOS BSD date)
TODAY_2PM=$(date -j -f "%Y-%m-%d %H:%M:%S" "$(date +%Y-%m-%d) 14:00:00" +"%Y-%m-%dT%H:%M:%S%z" | sed -E 's/([+-][0-9]{2})([0-9]{2})$/\1:\2/')

# Explicit absolute timestamps are always portable
START="2026-01-15T09:00:00Z"
END="2026-01-15T10:00:00+11:00"
```

For relative dates beyond today/tomorrow/next (e.g. "next Monday at 9am"), reach for a portable date library like `dateutils`, or compute the date in the calling script's language.

## Calendar discovery

### Find calendar by name
```bash
WORK_ID=$(ekctl list calendars | jq -r '.calendars[] | select(.title == "Work") | .id')

# Get ID of reminder list named "Groceries"
GROCERIES_ID=$(ekctl list calendars | jq -r '.calendars[] | select(.title == "Groceries" and .type == "reminder") | .id')
```

### List only event calendars
```bash
ekctl list calendars | jq '.calendars[] | select(.type == "event")'
```

### List only reminder lists
```bash
ekctl list calendars | jq '.calendars[] | select(.type == "reminder")'
```

### Find calendars that allow modifications
```bash
ekctl list calendars | jq '.calendars[] | select(.allowsModifications == true)'
```

## Event queries

### Today's events (use the shortcut)
```bash
ekctl today --calendar work
```

### Tomorrow's events
```bash
ekctl tomorrow --calendar work
```

### Next 5 events across multiple calendars
```bash
ekctl next --calendar work,personal --count 5
```

### Events with specific title (use --search)
```bash
ekctl today --calendar work --search "Meeting"
ekctl next --calendar work --search "1:1" --count 10 --days 30
```

### Events at specific location (use --search)
```bash
ekctl next --calendar work --search "Room 301" --days 30
```

### Busy events only (use --availability)
```bash
ekctl today --calendar work --availability busy
```

### All-day events only (still needs jq — no built-in flag yet)
```bash
ekctl next --calendar work --count 100 --days 30 | \
  jq '.events[] | select(.allDay == true)'
```

### Events with alarms (still needs jq)
```bash
ekctl next --calendar work --count 100 --days 30 | \
  jq '.events[] | select(.hasAlarms == true)'
```

### Recurring events (still needs jq)
```bash
ekctl next --calendar work --count 100 --days 30 | \
  jq '.events[] | select(.hasRecurrenceRules == true)'
```

### Events at a specific custom date range
For ranges that aren't today/tomorrow/next, fall back to explicit `--from`/`--to`:
```bash
ekctl list events --calendar work \
  --from "2026-02-01T00:00:00Z" --to "2026-02-29T23:59:59Z"
```

## Output formatting

### Export to CSV (built-in, no jq needed)
```bash
ekctl list events --calendar work \
  --from "2026-01-01T00:00:00Z" --to "2026-12-31T23:59:59Z" \
  --format csv > events.csv
```

The CSV header is the union of every field present in the returned events, alphabetised — so new fields like `availability` and `attendees` appear automatically without changing the command. Nested arrays (like `attendees`) become a JSON-encoded cell so you can re-parse them later if needed.

### Greppable text output
```bash
ekctl today --calendar work --format text | grep -i conference
```

### Custom field selection with jq (when CSV isn't quite right)
```bash
ekctl today --calendar work | \
  jq -r '.events[] | [.title, .startDate, .endDate, .location // ""] | @tsv'
```

### Event list as compact table
```bash
ekctl today --calendar work | \
  jq -r '.events[] | "\(.startDate | split("T")[1] | split("+")[0]) - \(.title)"'
```

### Pretty-print event summary
```bash
ekctl today --calendar work | \
  jq -r '.events[] | "Title:    \(.title)\nTime:     \(.startDate) - \(.endDate)\nLocation: \(.location // "None")\nBusy:     \(.availability)\n"'
```

Or use the built-in text format if you don't need a custom layout:
```bash
ekctl today --calendar work --format text
```

## Reminder queries

### Search reminders by substring (built-in)
```bash
ekctl list reminders --list personal --search milk
```

### Incomplete reminders
```bash
ekctl list reminders --list personal --completed false
```

### Overdue reminders (jq for date comparison)
```bash
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
ekctl list reminders --list personal --completed false | \
  jq --arg now "$NOW" '.reminders[] | select(.dueDate != null and .dueDate < $now)'
```

### High-priority reminders
```bash
ekctl list reminders --list personal --completed false | \
  jq '.reminders[] | select(.priority == 1)'
```

### Reminders due today
```bash
TODAY=$(date -u +"%Y-%m-%dT00:00:00Z")
TOMORROW=$(date -u -v+1d +"%Y-%m-%dT00:00:00Z")
ekctl list reminders --list personal --completed false | \
  jq --arg today "$TODAY" --arg tomorrow "$TOMORROW" \
  '.reminders[] | select(.dueDate != null and .dueDate >= $today and .dueDate < $tomorrow)'
```

### Count incomplete reminders
```bash
ekctl list reminders --list personal --completed false | jq '.count'
```

## Batch operations

### Create multiple events
```bash
for day in 15 16 17 18 19; do
  ekctl add event \
    --calendar work \
    --title "Daily Standup" \
    --start "2026-01-${day}T09:00:00Z" \
    --end "2026-01-${day}T09:15:00Z"
done
```

Or use a single recurring event instead:
```bash
ekctl add event \
  --calendar work \
  --title "Daily Standup" \
  --start "2026-01-15T09:00:00Z" \
  --end "2026-01-15T09:15:00Z" \
  --recurrence-frequency daily \
  --recurrence-end-count 5
```

### Create events from a JSON file
```bash
# events.json:
# [
#   {"title": "Meeting 1", "start": "2026-01-15T10:00:00Z", "end": "2026-01-15T11:00:00Z"},
#   {"title": "Meeting 2", "start": "2026-01-16T14:00:00Z", "end": "2026-01-16T15:00:00Z"}
# ]

cat events.json | jq -c '.[]' | while read event; do
  TITLE=$(echo "$event" | jq -r '.title')
  START=$(echo "$event" | jq -r '.start')
  END=$(echo "$event" | jq -r '.end')
  ekctl add event --calendar work --title "$TITLE" --start "$START" --end "$END"
done
```

### Complete all reminders in a list
```bash
ekctl list reminders --list groceries --completed false | \
  jq -r '.reminders[].id' | \
  while read id; do
    ekctl complete reminder "$id"
  done
```

### Delete all events on a specific day
```bash
ekctl today --calendar test-calendar | \
  jq -r '.events[].id' | \
  while read id; do
    ekctl delete event "$id"
  done
```

## Integration patterns

### Sync with an external service
```bash
# Example: Create events from an API response
curl -s "https://api.example.com/meetings" | \
  jq -c '.meetings[]' | \
  while read meeting; do
    TITLE=$(echo "$meeting" | jq -r '.subject')
    START=$(echo "$meeting" | jq -r '.startTime')
    END=$(echo "$meeting" | jq -r '.endTime')
    ekctl add event --calendar work --title "$TITLE" --start "$START" --end "$END"
  done
```

### Daily summary script
```bash
#!/bin/bash
# daily-summary.sh

echo "=== Today's events ==="
ekctl today --calendar work --format text

echo ""
echo "=== Tomorrow's events ==="
ekctl tomorrow --calendar work --format text

echo ""
echo "=== Pending reminders ==="
ekctl list reminders --list personal --completed false --format text
```

Or as a single compact view:
```bash
#!/bin/bash
ekctl today --calendar work | \
  jq -r '"Today: \(.count) events"; .events[] | "  \(.startDate | split("T")[1] | split("+")[0][:5]) \(.title)"'

ekctl list reminders --list personal --completed false | \
  jq -r '"Pending reminders: \(.count)"; .reminders[] | "  - \(.title)\(.dueDate | if . then " (due " + (split("T")[0]) + ")" else "" end)"'
```

### Error handling in scripts
```bash
#!/bin/bash
set -e

result=$(ekctl add event --calendar work --title "Test" \
  --start "2026-01-15T10:00:00Z" --end "2026-01-15T11:00:00Z")
status=$(echo "$result" | jq -r '.status')

if [ "$status" = "error" ]; then
  error=$(echo "$result" | jq -r '.error')
  echo "Failed to create event: $error" >&2
  exit 1
fi

event_id=$(echo "$result" | jq -r '.event.id')
echo "Created event: $event_id"
```

### Find my next free 30-minute window today
```bash
# Get today's busy events sorted by start
ekctl today --calendar work --availability busy | \
  jq -r '[.events[] | {start: .startDate, end: .endDate}] | sort_by(.start) | .[] | "\(.start) \(.end)"'
# Pipe through your own gap-finder; built-in free/busy is a future feature.
```

## Alias setup script

Quick setup for common calendars:
```bash
#!/bin/bash
# setup-aliases.sh

echo "Setting up ekctl aliases..."

ekctl list calendars | jq -r '.calendars[] | "\(.title)|\(.id)|\(.type)"' | while IFS='|' read title id type; do
  case "$title" in
    "Work"|"work")
      ekctl alias set work "$id"
      echo "Set alias 'work' for $title"
      ;;
    "Personal"|"personal"|"Home")
      if [ "$type" = "event" ]; then
        ekctl alias set personal "$id"
        echo "Set alias 'personal' for $title"
      else
        ekctl alias set reminders "$id"
        echo "Set alias 'reminders' for $title"
      fi
      ;;
    "Grocery"|"Groceries"|"Shopping")
      ekctl alias set groceries "$id"
      echo "Set alias 'groceries' for $title"
      ;;
  esac
done

echo ""
echo "Current aliases:"
ekctl alias list --format text
```
