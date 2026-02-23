---
name: calendar-operations
description: Fetch and display Apple Calendar events.
user-invocable: true
---

# Calendar Operations

Access Apple Calendar using the `plan` CLI at `/opt/homebrew/bin/plan`.

## Command Mapping

Map user queries to the appropriate command:

| User Query | Command |
|------------|---------|
| "What's on my calendar today?" | `plan today` |
| "What do I have tomorrow?" | `plan on tomorrow` |
| "Show me next Tuesday's events" | `plan on "next tuesday"` |
| "What's my next meeting?" | `plan next` |
| "List my calendars" | `plan calendars` |
| "How many hours of meetings today?" | `plan hours today` |
| "Events on April 3rd" | `plan on "2026-04-03"` |

## Commands

### today

```bash
/opt/homebrew/bin/plan today
/opt/homebrew/bin/plan today --ignore-calendar-types birthday
/opt/homebrew/bin/plan today --ignore-all-day-events
```

### on \<expression\>

Date expressions: ISO dates (`"2026-04-03"`), natural language (`"tomorrow"`, `"next tuesday"`, `"last monday"`).

```bash
/opt/homebrew/bin/plan on tomorrow
/opt/homebrew/bin/plan on "next friday"
/opt/homebrew/bin/plan on "2026-04-03" --ignore-all-day-events
```

### next

Finds the next upcoming event. `--within` is in minutes (default: 60).

```bash
/opt/homebrew/bin/plan next
/opt/homebrew/bin/plan next --within 240
/opt/homebrew/bin/plan next --min-num-attendees 1
```

### calendars

```bash
/opt/homebrew/bin/plan calendars
/opt/homebrew/bin/plan calendars --format plain
```

### hours \<expression\>

Calculates total hours per event on a date.

```bash
/opt/homebrew/bin/plan hours today
/opt/homebrew/bin/plan hours yesterday --select-calendar-labels "Work"
/opt/homebrew/bin/plan hours today --ignore-all-day-events
```

## Output

All commands output JSON. For the full JSON schema and advanced filtering/sorting options, read `filters.md` in this skill directory.

## Presenting Results

1. Parse the JSON output
2. Sort by start time (unless user specifies otherwise)
3. Show time ranges clearly
4. Highlight important details (location, attendees, calendar)
5. Format all-day events differently
6. Handle empty results gracefully ("No events found")
7. For `hours`, summarize total hours and breakdown by event
