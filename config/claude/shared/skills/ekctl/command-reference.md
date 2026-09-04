# ekctl Command Reference

Complete reference for all ekctl commands. Targets ekctl 1.4.0.

Every output-producing command accepts `--format json|csv|text` (default `json`). Examples below show JSON output unless noted.

## Quick Date-Range Commands

Top-level shortcuts that wrap `list events` with a pre-computed local date range. Composable with `--search`, `--availability`, `--format`, and comma-separated `--calendar`.

### List today's events
```bash
ekctl today --calendar <id_or_alias>
```

### List tomorrow's events
```bash
ekctl tomorrow --calendar <id_or_alias>
```

### List upcoming events
```bash
ekctl next --calendar <id_or_alias> [--count <N>] [--days <N>]
```

**Flags:**
- `--calendar`: Calendar ID or alias. Comma-separated for multiple calendars.
- `--count`: Number of upcoming events to return (default: 1).
- `--days`: Lookahead window in days (default: 90).
- `--search`: Case-insensitive substring filter across title/location/notes.
- `--availability`: Filter by EKEventAvailability (busy, free, tentative, unavailable, notSupported).
- `--format`: Output format (json, csv, text; default: json).

**Examples:**
```bash
# Single next event
ekctl next --calendar work

# Next 3 events that mention "standup"
ekctl next --calendar work --count 3 --search standup

# Tomorrow's busy meetings as CSV
ekctl tomorrow --calendar work --availability busy --format csv

# Today across two calendars
ekctl today --calendar work,personal
```

`next` returns events sorted by start time ascending and includes events currently in progress (their `endDate` is still in the future).

---

## Alias Commands

Manage friendly names for calendars and reminder lists.

### Set an alias
```bash
ekctl alias set <name> <calendar_or_list_id>
```

**Examples:**
```bash
ekctl alias set work "CA513B39-1659-4359-8FE9-0C2A3DCEF153"
ekctl alias set groceries "E30AE972-8F29-40AF-BFB9-E984B98B08AB"
```

**Output:**
```json
{
  "status": "success",
  "message": "Alias 'work' set successfully",
  "alias": {
    "name": "work",
    "id": "CA513B39-1659-4359-8FE9-0C2A3DCEF153"
  }
}
```

### List all aliases
```bash
ekctl alias list
```

**Output:**
```json
{
  "aliases": [
    { "name": "groceries", "id": "E30AE972-8F29-40AF-BFB9-E984B98B08AB" },
    { "name": "work", "id": "CA513B39-1659-4359-8FE9-0C2A3DCEF153" }
  ],
  "count": 2,
  "configPath": "/Users/you/.ekctl/config.json",
  "status": "success"
}
```

### Remove an alias
```bash
ekctl alias remove <name>
```

---

## Calendar Commands

### List all calendars
```bash
ekctl list calendars
```

Returns both event calendars and reminder lists.

**Output:**
```json
{
  "calendars": [
    {
      "id": "CA513B39-1659-4359-8FE9-0C2A3DCEF153",
      "title": "Work",
      "type": "event",
      "source": "iCloud",
      "color": "#0088FF",
      "allowsModifications": true
    },
    {
      "id": "E30AE972-8F29-40AF-BFB9-E984B98B08AB",
      "title": "Grocery",
      "type": "reminder",
      "source": "iCloud",
      "color": "#F6CE32",
      "allowsModifications": true
    }
  ],
  "status": "success"
}
```

**Key fields:**
- `type`: Either `"event"` (calendar) or `"reminder"` (reminder list)
- `allowsModifications`: Whether you can add/edit/delete items
- `color`: Hex string for the calendar's display color

### Create a calendar
```bash
ekctl calendar create --title "<title>" [--color "#RRGGBB"]
```

### Update a calendar
```bash
ekctl calendar update <calendar_id> [--title "<new title>"] [--color "#RRGGBB"]
```

### Delete a calendar
```bash
ekctl calendar delete <calendar_id>
```

---

## Event Commands

### List events
```bash
ekctl list events --calendar <id_or_alias> --from <ISO8601> --to <ISO8601>
```

**Required flags:**
- `--calendar`: Calendar ID or alias. **Comma-separated for multiple calendars** (e.g., `work,personal`).
- `--from`: Start date (ISO 8601).
- `--to`: End date (ISO 8601).

**Optional flags:**
- `--search`: Case-insensitive substring filter across title, location, and notes.
- `--availability`: Filter by EKEventAvailability (busy, free, tentative, unavailable, notSupported).
- `--format`: Output format (json, csv, text).

**Examples:**
```bash
# Using alias
ekctl list events --calendar work --from "2026-01-01T00:00:00Z" --to "2026-01-31T23:59:59Z"

# Multi-calendar
ekctl list events --calendar work,personal --from "2026-01-01T00:00:00Z" --to "2026-01-31T23:59:59Z"

# Filtered
ekctl list events --calendar work --from "2026-01-01T00:00:00Z" --to "2026-01-31T23:59:59Z" \
  --search "standup" --availability busy

# As CSV
ekctl list events --calendar work --from "2026-01-01T00:00:00Z" --to "2026-01-31T23:59:59Z" \
  --format csv > events.csv
```

For "today" / "tomorrow" / "next N" use the dedicated subcommands above rather than computing dates yourself.

**Output:**
```json
{
  "count": 1,
  "events": [
    {
      "id": "ABC123:DEF456",
      "title": "Team Meeting",
      "calendar": {
        "id": "CA513B39-1659-4359-8FE9-0C2A3DCEF153",
        "title": "Work"
      },
      "startDate": "2026-01-15T09:00:00+11:00",
      "endDate": "2026-01-15T10:00:00+11:00",
      "location": "Conference Room A",
      "notes": "Weekly sync meeting",
      "url": null,
      "allDay": false,
      "hasAlarms": true,
      "hasRecurrenceRules": false,
      "availability": "busy",
      "attendees": [
        {
          "name": "Jane Doe",
          "email": "jane@example.com",
          "status": "accepted",
          "role": "required"
        }
      ]
    }
  ],
  "status": "success"
}
```

### Show event details
```bash
ekctl show event <event_id>
```

### Add event
```bash
ekctl add event \
  --calendar <id_or_alias> \
  --title "<title>" \
  --start <ISO8601> \
  --end <ISO8601> \
  [--location "<location>"] \
  [--notes "<notes>"] \
  [--all-day] \
  [--url "<url>"] \
  [--availability busy|free|tentative|unavailable] \
  [--alarms "<minute_offsets>"] \
  [--travel-time <minutes>] \
  [--recurrence-frequency daily|weekly|monthly] \
  [--recurrence-interval <N>] \
  [--recurrence-end-count <N>] \
  [--recurrence-end-date <ISO8601>] \
  [--recurrence-days "<MO,TU,WE,...>"] \
  [--recurrence-days-of-month "<1,15,-1>"]
```

**Required flags:**
- `--calendar`: Calendar ID or alias
- `--title`: Event title
- `--start`: Start date/time (ISO 8601)
- `--end`: End date/time (ISO 8601)

**Optional flags:**
- `--location`: Event location (geocoded automatically to a structured location)
- `--notes`: Event notes/description
- `--all-day`: Mark as all-day event
- `--url`: Associated URL
- `--availability`: One of `busy`, `free`, `tentative`, `unavailable`
- `--alarms`: Comma-separated minute offsets. Positive = minutes before start (e.g., `10,60` = 10 and 60 minutes before). Prefix `+` for minutes after (e.g., `+15`). Replaces all existing alarms.
- `--travel-time`: Travel time in minutes (uses a private EventKit KVC path)
- `--recurrence-frequency`: `daily`, `weekly`, or `monthly`
- `--recurrence-interval`: Interval between recurrences (default 1)
- `--recurrence-end-count`: Stop after N occurrences
- `--recurrence-end-date`: Stop at this date (ISO 8601)
- `--recurrence-days`: Two-letter weekday list (`MO,TU,WE,TH,FR,SA,SU`)
- `--recurrence-days-of-month`: Comma-separated days (`-1` = last day of month)

**Examples:**
```bash
# Basic event
ekctl add event \
  --calendar work \
  --title "Lunch Meeting" \
  --start "2026-01-15T12:00:00Z" \
  --end "2026-01-15T13:00:00Z"

# Event with location, alarm 10 minutes before, and URL
ekctl add event \
  --calendar work \
  --title "Project Review" \
  --start "2026-01-15T14:00:00Z" \
  --end "2026-01-15T15:30:00Z" \
  --location "Building 2, Room 301" \
  --notes "Bring Q1 reports" \
  --alarms 10 \
  --url "https://meet.example.com/project-review"

# Weekly recurring 1:1 for the next 12 weeks
ekctl add event \
  --calendar work \
  --title "1:1 with Manager" \
  --start "2026-01-15T14:00:00Z" \
  --end "2026-01-15T14:30:00Z" \
  --recurrence-frequency weekly \
  --recurrence-end-count 12

# Multi-day all-day event marked free (vacation)
ekctl add event \
  --calendar personal \
  --title "Vacation" \
  --start "2026-01-20T00:00:00Z" \
  --end "2026-01-25T00:00:00Z" \
  --all-day \
  --availability free
```

### Update event
```bash
ekctl update event <event_id> \
  [--title "<new title>"] \
  [--start <ISO8601>] \
  [--end <ISO8601>] \
  [--location "<location>"] \
  [--notes "<notes>"] \
  [--url "<url>"] \
  [--availability busy|free|tentative|unavailable] \
  [--travel-time <minutes>] \
  [--alarms "<minute_offsets>"] \
  [--all-day true|false]
```

Only the supplied flags are changed. `--alarms` replaces the existing alarm set (pass an empty string to clear, or specific offsets to overwrite).

**Example:**
```bash
ekctl update event "EVENT_ID" --title "Renamed meeting" --location "New room"
```

### Delete event
```bash
ekctl delete event <event_id>
```

**Output:**
```json
{
  "status": "success",
  "message": "Event 'Team Meeting' deleted successfully",
  "deletedEventID": "ABC123:DEF456"
}
```

---

## Reminder Commands

### List reminders
```bash
ekctl list reminders --list <id_or_alias> [--completed <true|false>] [--search "<term>"]
```

**Required flags:**
- `--list`: Reminder list ID or alias

**Optional flags:**
- `--completed`: Filter by completion status (`true`, `false`, or omit for all)
- `--search`: Case-insensitive substring filter across title and notes
- `--format`: Output format (json, csv, text)

**Examples:**
```bash
# All reminders
ekctl list reminders --list personal

# Only incomplete
ekctl list reminders --list personal --completed false

# Only completed
ekctl list reminders --list personal --completed true

# Substring filter
ekctl list reminders --list groceries --search milk

# As CSV
ekctl list reminders --list personal --completed false --format csv
```

**Output:**
```json
{
  "count": 1,
  "reminders": [
    {
      "id": "REM123-456-789",
      "title": "Buy groceries",
      "list": {
        "id": "4E367C6F-354B-4811-935E-7F25A1BB7D39",
        "title": "Personal"
      },
      "dueDate": "2026-01-20T17:00:00+11:00",
      "completed": false,
      "priority": 0,
      "notes": null,
      "url": null
    }
  ],
  "status": "success"
}
```

### Show reminder details
```bash
ekctl show reminder <reminder_id>
```

### Add reminder
```bash
ekctl add reminder \
  --list <id_or_alias> \
  --title "<title>" \
  [--due <ISO8601>] \
  [--priority <0-9>] \
  [--notes "<notes>"]
```

**Required flags:**
- `--list`: Reminder list ID or alias
- `--title`: Reminder title

**Optional flags:**
- `--due`: Due date/time (ISO 8601). Stored zoned to render correctly on iCloud Web.
- `--priority`: Integer priority (0=none, 1=high, 5=medium, 9=low). Non-integer input is rejected with a JSON error.
- `--notes`: Additional notes

**Examples:**
```bash
# Simple reminder
ekctl add reminder --list personal --title "Call the dentist"

# With due date
ekctl add reminder \
  --list personal \
  --title "Submit expense report" \
  --due "2026-01-25T09:00:00Z"

# With priority and notes
ekctl add reminder \
  --list groceries \
  --title "Buy milk" \
  --due "2026-01-16T10:00:00Z" \
  --priority 1 \
  --notes "Check expiration date"
```

**Output:**
```json
{
  "status": "success",
  "message": "Reminder created successfully",
  "reminder": {
    "id": "NEWREM-123-456",
    "title": "Submit expense report",
    "list": {
      "id": "4E367C6F-354B-4811-935E-7F25A1BB7D39",
      "title": "Personal"
    },
    "dueDate": "2026-01-25T09:00:00+11:00",
    "completed": false,
    "priority": 0,
    "notes": null,
    "url": null
  }
}
```

### Update reminder
```bash
ekctl update reminder <reminder_id> \
  [--title "<new title>"] \
  [--due <ISO8601>] \
  [--priority <0-9>] \
  [--notes "<notes>"] \
  [--completed true|false]
```

Only the supplied flags change. Pass `--completed true` to mark done (equivalent to `complete reminder`); pass `--completed false` to re-open a completed reminder.

**Example:**
```bash
ekctl update reminder "REMINDER_ID" --due "2026-01-17T10:00:00Z" --priority 5
```

### Complete reminder
```bash
ekctl complete reminder <reminder_id>
```

**Output:**
```json
{
  "status": "success",
  "message": "Reminder 'Buy groceries' marked as completed",
  "reminder": {
    "id": "REM123-456-789",
    "title": "Buy groceries",
    "completed": true,
    "completionDate": "2026-01-21T10:30:00+11:00"
  }
}
```

### Delete reminder
```bash
ekctl delete reminder <reminder_id>
```

---

## Output Format Reference

All output-producing commands accept `--format json|csv|text`.

### JSON (default)

Pretty-printed, sorted-keys. The shape documented in each section above is what you get.

### CSV (`--format csv`)

- Header is the union of every field across the returned items, alphabetised.
- Nested objects flatten with dot notation (`calendar.id`, `calendar.title`).
- Nested arrays (like `attendees`) become a single JSON-encoded cell.
- RFC 4180 escaping: fields with comma, double-quote, newline, or CR get wrapped in quotes; internal quotes doubled.
- CRLF line endings.
- An empty list produces an empty string.
- Errors render as a single `error,status` row.

### Text (`--format text`)

- One `key: value` line per field, alphabetised within each item.
- Blank line between items.
- Greppable.

---

## Help Commands

Get help for any command:
```bash
ekctl --help
ekctl list --help
ekctl add event --help
ekctl alias --help
ekctl today --help
ekctl next --help
```

Check version:
```bash
ekctl --version
```
