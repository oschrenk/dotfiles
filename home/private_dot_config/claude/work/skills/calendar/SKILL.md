---
name: calendar
description: Fetch calendar events and calculate worked hours from Apple Calendar. Use when the user asks about Timewax hours, worked hours, time tracking, hours worked this week/last week, or their schedule/meetings/calendar.
---

# Calendar

This skill interacts with Apple Calendar using the `plan` CLI tool at `/opt/homebrew/bin/plan`.

## Commands

### View Today's Events
```bash
/opt/homebrew/bin/plan today
```

### View Events on a Date
```bash
/opt/homebrew/bin/plan on <expression>
```
The expression can be:
- A date: `2025-11-25`
- Natural language: `"last tuesday"`, `"next friday"`, `"yesterday"`

### View Next Event
```bash
/opt/homebrew/bin/plan next
```
Options:
- `--within <m>`: Fetch events within `m` minutes (default: 60)

### List Available Calendars
```bash
/opt/homebrew/bin/plan calendars
```

### Calculate Hours for a Date
```bash
/opt/homebrew/bin/plan hours <expression>
```
Same date expressions as `on` command.

## Filters

All filters work with `today`, `on`, `hours`, and `next` commands.

### Calendar Filters
| Filter | Description |
|--------|-------------|
| `--select-calendar-labels <v>` | Only events from calendars with label(s) (comma-separated) |
| `--ignore-calendar-labels <v>` | Exclude calendars with label(s) |
| `--select-calendar-types <v>` | Only: local, caldav, exchange, subscription, birthday |
| `--ignore-calendar-types <v>` | Exclude calendar types |
| `--select-calendar-sources <s>` | Only events from source(s) |
| `--ignore-calendar-sources <s>` | Exclude sources |
| `--select-calendar-ids <v>` | Only calendars with UUID(s) |
| `--ignore-calendar-ids <v>` | Exclude calendar UUIDs |

### Event Filters
| Filter | Description |
|--------|-------------|
| `--select-title <p>` | Only events with matching title pattern |
| `--ignore-title <p>` | Exclude events with matching title |
| `--select-all-day-events` | Only all-day events |
| `--ignore-all-day-events` | Exclude all-day events |
| `--select-tags <t>` | Only events with tag in notes (e.g., `tag:timeblock`) |
| `--ignore-tags <t>` | Exclude events with tag |
| `--select-services <s>` | Only events with service |
| `--ignore-services <s>` | Exclude events with service |

### Attendee & Duration Filters
| Filter | Description |
|--------|-------------|
| `--min-num-attendees <n>` | Minimum number of attendees |
| `--max-num-attendees <n>` | Maximum number of attendees |
| `--min-duration <m>` | Minimum duration in minutes |
| `--max-duration <m>` | Maximum duration in minutes |

### Sorting
```bash
--sort-by <field[:asc|desc]>
```
Available fields: `id`, `calendar.id`, `calendar.type`, `calendar.label`, `calendar.color`, `title.full`, `title.label`, `title.icon`, `schedule.start.at`, `schedule.start.in`, `schedule.end.at`, `schedule.end.in`, `schedule.all_day`, `location`, `meeting.organizer`

## Timewax Hours Tracking

This is the primary use case for calculating worked hours from calendar events.

### Workflow

1. **Get today's date and day of week** - Run this first to determine correct dates:
   ```bash
   date "+%Y-%m-%d %A"
   ```
2. **Calculate the date range** based on the day of week (see below)
3. **Run the hours command for each day in parallel:**
   ```bash
   /opt/homebrew/bin/plan hours --select-title Timewax YYYY-MM-DD
   ```
4. **Parse the output** - each command returns: `🕐 Timewax: H.MM` (e.g., `🕐 Timewax: 6.50`)
5. **Sum the hours** and present results

### Date Calculation

**Always run `date "+%Y-%m-%d %A"` first** to get the correct current date and day of week.

| User Request | Date Range |
|--------------|------------|
| "this week" | Monday of current week through today |
| "last week" | Monday-Friday of the previous week |
| "last N days" | N days ending yesterday |
| Custom range | User-specified start and end dates |

**Finding Monday of this week:**
- If today is Monday (day 1): Monday = today
- If today is Tuesday (day 2): Monday = today - 1 day
- If today is Wednesday (day 3): Monday = today - 2 days
- If today is Thursday (day 4): Monday = today - 3 days
- If today is Friday (day 5): Monday = today - 4 days

**Finding Monday of last week:** Subtract 7 more days from this week's Monday.

### Output Format

Present hours as a daily breakdown with totals:
```
Mon Jan 20: 7.50h
Tue Jan 21: 8.00h
Wed Jan 22: 6.25h
Thu Jan 23: 8.00h
Fri Jan 24: 7.75h
─────────────────
Total: 37.50h (avg 7.50h/day)
```

### Handling Empty Days

If a day returns no output or `0.00`, include it as `0.00h` in the breakdown. This indicates no Timewax events were scheduled that day.

## Output Format (Other Commands)

Commands like `today`, `on`, and `next` return JSON with these fields:
- `title.label`: Event title
- `schedule.start.at`: Start time (ISO 8601)
- `schedule.end.at`: End time (ISO 8601)
- `schedule.all_day`: Boolean for all-day events
- `calendar.label`: Calendar name
- `location`: Event location (if present)
- `meeting.attendees`: List of attendees

## Error Handling

| Situation | Response |
|-----------|----------|
| Empty output | "No events found for [date/filter]" |
| Command fails | Check if `plan` is installed at `/opt/homebrew/bin/plan` |
| Invalid date | Use YYYY-MM-DD or natural language like "last tuesday" |
| No matching events | Suggest removing filters or checking calendar names with `plan calendars` |

## Examples

### Hours Tracking

**"How many hours did I work this/last week?"**

Step 1 - Get today's date:
```bash
date "+%Y-%m-%d %A"
```

Step 2 - Calculate the Monday of the target week based on day of week, then run for each weekday through today (this week) or Mon-Fri (last week):
```bash
/opt/homebrew/bin/plan hours --select-title Timewax YYYY-MM-DD
```

Run one command per day in parallel, then sum the results.

### Calendar Queries

**What's on my calendar today?**
```bash
/opt/homebrew/bin/plan today --ignore-calendar-types birthday
```

**What meetings do I have tomorrow?**
```bash
/opt/homebrew/bin/plan on tomorrow --min-num-attendees 1
```

**Events from last Tuesday:**
```bash
/opt/homebrew/bin/plan on "last tuesday"
```

**What's my next meeting?**
```bash
/opt/homebrew/bin/plan next --within 120 --min-num-attendees 1
```

**Show only work calendar:**
```bash
/opt/homebrew/bin/plan today --select-calendar-labels "Work"
```
