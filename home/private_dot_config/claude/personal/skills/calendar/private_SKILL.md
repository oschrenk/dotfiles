---
name: calendar
description: Fetch and display calendar events from Apple Calendar. Supports viewing events for today, specific dates, next event, listing calendars, and calculating hours. Use when the user asks about their schedule, meetings, appointments, or calendar.
---

# Calendar

This skill provides comprehensive access to Apple Calendar using the `plan` CLI tool.

## Available Commands

The `plan` CLI supports five main commands:
- `today` - List today's events
- `on <expression>` - List events on a specific date
- `next` - Find the next upcoming event
- `calendars` - List available calendars
- `hours <expression>` - Calculate hours per event on a date

## Command Mapping

Map user queries to the appropriate command:

| User Query | Command |
|------------|---------|
| "What's on my calendar today?" | `plan today` |
| "What do I have tomorrow?" | `plan on tomorrow` |
| "Show me next Tuesday's events" | `plan on "next tuesday"` |
| "What's my next meeting?" | `plan next` |
| "List my calendars" | `plan calendars` |
| "How many hours of meetings yesterday?" | `plan hours yesterday` |
| "Events on April 3rd" | `plan on "2025-04-03"` |

## 1. Today's Events (`plan today`)

Lists all events happening today.

**Basic usage:**
```bash
/opt/homebrew/bin/plan today
```

**Common filters:**
```bash
# Skip birthdays
/opt/homebrew/bin/plan today --ignore-calendar-types birthday

# Only work calendar
/opt/homebrew/bin/plan today --select-calendar-labels "Work"

# Only meetings with attendees
/opt/homebrew/bin/plan today --min-num-attendees 1

# Skip all-day events
/opt/homebrew/bin/plan today --ignore-all-day-events
```

## 2. Events on Specific Date (`plan on <expression>`)

Lists events on a specific date using flexible date expressions.

**Date expression formats:**
- ISO dates: `"2025-04-03"`
- Natural language: `"tomorrow"`, `"next tuesday"`, `"last monday"`

**Usage:**
```bash
# Tomorrow's events
/opt/homebrew/bin/plan on tomorrow

# Specific date
/opt/homebrew/bin/plan on "2025-04-03"

# Natural language
/opt/homebrew/bin/plan on "next friday"

# With filters
/opt/homebrew/bin/plan on tomorrow --ignore-all-day-events
```

## 3. Next Event (`plan next`)

Finds the next upcoming event.

**Usage:**
```bash
# Next event within the next hour (default)
/opt/homebrew/bin/plan next

# Next event within the next 4 hours
/opt/homebrew/bin/plan next --within 240

# Next meeting (with attendees)
/opt/homebrew/bin/plan next --min-num-attendees 1

# Next work event
/opt/homebrew/bin/plan next --select-calendar-labels "Work"
```

**Note:** `--within` parameter is in minutes (default: 60)

## 4. List Calendars (`plan calendars`)

Lists all available calendars.

**Usage:**
```bash
# JSON output (default)
/opt/homebrew/bin/plan calendars

# Plain text output
/opt/homebrew/bin/plan calendars --format plain

# Filter by type
/opt/homebrew/bin/plan calendars --select-calendar-types caldav
```

## 5. Hours Calculation (`plan hours <expression>`)

Calculates total hours per event on a specific date.

**Usage:**
```bash
# Today's hours
/opt/homebrew/bin/plan hours today

# Yesterday's hours
/opt/homebrew/bin/plan hours yesterday

# Specific date
/opt/homebrew/bin/plan hours "2025-04-03"

# Only count work calendar
/opt/homebrew/bin/plan hours today --select-calendar-labels "Work"

# Exclude all-day events from calculation
/opt/homebrew/bin/plan hours today --ignore-all-day-events
```

## Common Filtering Options

All event-based commands support these filters:

**Calendar filtering:**
- `--select-calendar-ids <ids>` - Select by calendar UUID
- `--ignore-calendar-ids <ids>` - Ignore by calendar UUID
- `--select-calendar-labels <labels>` - Select by name (comma-separated)
- `--ignore-calendar-labels <labels>` - Ignore by name (comma-separated)
- `--select-calendar-types <types>` - Types: local, caldav, exchange, subscription, birthday
- `--ignore-calendar-types <types>` - Ignore specific types
- `--select-calendar-sources <sources>` - Select by source
- `--ignore-calendar-sources <sources>` - Ignore by source

**Event filtering:**
- `--ignore-all-day-events` - Skip all-day events
- `--select-all-day-events` - Only all-day events
- `--ignore-title <pattern>` - Ignore titles matching pattern
- `--select-title <pattern>` - Select titles matching pattern
- `--min-num-attendees <n>` - Minimum attendees (inclusive)
- `--max-num-attendees <n>` - Maximum attendees (inclusive)
- `--min-duration <m>` - Minimum duration in minutes (inclusive)
- `--max-duration <m>` - Maximum duration in minutes (inclusive)

**Tag and service filtering:**
- `--ignore-tags <tags>` - Ignore events with tags (e.g., 'tag:timeblock')
- `--select-tags <tags>` - Select events with tags
- `--ignore-services <services>` - Ignore events with services
- `--select-services <services>` - Select events with services

**Output customization:**
- `--sort-by <field[:direction]>` - Sort by field (asc/desc)
  - Available fields: id, calendar.id, calendar.type, calendar.label, title.full, schedule.start.at, schedule.end.at, location, meeting.organizer
- `--template-path <path>` - Custom template for output

## JSON Output Format

All commands output JSON with the following structure:
```json
{
  "title": {"label": "Event Title", "icon": "📅", "full": "📅 Event Title"},
  "schedule": {
    "start": {"at": "2025-04-03T10:00:00", "in": "..."},
    "end": {"at": "2025-04-03T11:00:00", "in": "..."},
    "all_day": false
  },
  "calendar": {"id": "...", "label": "Work", "type": "caldav", "color": "..."},
  "location": "Conference Room A",
  "meeting": {
    "organizer": "...",
    "attendees": [...]
  }
}
```

## Instructions for Parsing and Presenting

1. Run the appropriate `plan` command based on the user's query
2. Parse the JSON output
3. Present events in a user-friendly format:
   - Sort by start time (unless user specifies otherwise)
   - Show time ranges clearly
   - Highlight important details (location, attendees, calendar)
   - Format all-day events differently
4. Handle empty results gracefully ("No events found")
5. For `hours` command, summarize total hours and breakdown by event

## Example Workflows

**Morning briefing:**
```bash
# What's on today, excluding birthdays
/opt/homebrew/bin/plan today --ignore-calendar-types birthday
```

**Planning ahead:**
```bash
# Next week's specific day
/opt/homebrew/bin/plan on "next monday"
```

**Quick check:**
```bash
# What's next?
/opt/homebrew/bin/plan next --within 120
```

**Time tracking:**
```bash
# How many meeting hours this week?
/opt/homebrew/bin/plan hours today --min-num-attendees 1
```
