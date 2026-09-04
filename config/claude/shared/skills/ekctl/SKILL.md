---
name: ekctl
description: Manage macOS Calendar events and Reminders using the ekctl CLI tool.
user-invocable: true
---

# ekctl - macOS Calendar & Reminders CLI

Use the `ekctl` command-line tool to manage Calendar events and Reminders on macOS. Output defaults to JSON; CSV and plain-text are available on every command via `--format csv` and `--format text`.

## Workflow

### 1. Check for aliases first

Before any calendar/reminder operation, check if the user has aliases configured:
```bash
ekctl alias list
```

If aliases exist, use them instead of raw IDs. If no aliases exist, help the user set them up after listing calendars.

### 2. List available calendars

```bash
ekctl list calendars
```

This returns both event calendars (`type: "event"`) and reminder lists (`type: "reminder"`).

### 3. Set up aliases for convenience

Help users create aliases for frequently used calendars:
```bash
ekctl alias set work "CALENDAR_ID"
ekctl alias set personal "CALENDAR_ID"
ekctl alias set groceries "REMINDER_LIST_ID"
```

### 4. Perform requested operations

Use the appropriate command based on what the user wants to do. See `command-reference.md` for all commands and `scripting-examples.md` for jq patterns and integration recipes.

## Quick date ranges

Three top-level subcommands cover the most common queries with no date arithmetic required. Prefer these over computing `--from`/`--to` yourself:

```bash
ekctl today --calendar work          # events occurring today (local time)
ekctl tomorrow --calendar work       # events occurring tomorrow
ekctl next --calendar work           # the single next upcoming event
ekctl next --calendar work --count 5 # the next 5 upcoming events
ekctl next --calendar work --days 7  # only look 7 days ahead
```

`next` returns events sorted by start time and includes events currently in progress (their `endDate` is still in the future).

All three accept the same filter and format flags as `list events`, so they compose:
```bash
ekctl today --calendar work,personal --availability busy --format csv
ekctl next --calendar work --search standup --count 3 --format text
```

## Filtering

Two filters narrow `list events` and (`--search` only) `list reminders`. They compose with everything else:

- **`--search <term>`** — case-insensitive substring match across an event's title, location, and notes (or a reminder's title and notes). Use this instead of post-filtering through jq.
- **`--availability busy|free|tentative|unavailable|notSupported`** — events only. Filters to events whose EKEventAvailability matches.

```bash
# All standup-related events for the week
ekctl next --calendar work --search standup --days 7

# Only "busy" events today — actual blocked-out time
ekctl today --calendar work --availability busy

# Reminders that mention milk
ekctl list reminders --list groceries --search milk
```

## Output formats

Every output-producing command takes `--format`:

- **`json`** (default) — full structure, pretty-printed.
- **`csv`** — RFC 4180. Header is the union of every field across the returned items, alphabetised. Nested objects flatten to dot-notated columns (`calendar.id`, `calendar.title`); nested arrays (like `attendees`) become a JSON-encoded cell.
- **`text`** — `key: value` lines per item, blank line between items. Greppable.

CSV and text are auto-discovered from the same dictionary that produces JSON, so new fields appear in all three formats simultaneously — no drift.

```bash
ekctl today --calendar work --format csv > today.csv
ekctl list calendars --format text
```

## Multi-calendar

`--calendar` accepts a comma-separated list. Each returned event keeps its `calendar.id` and `calendar.title`, so the merged stream is still distinguishable:

```bash
ekctl today --calendar work,personal,family
ekctl list events --calendar work,personal --from "2026-02-01T00:00:00Z" --to "2026-02-28T23:59:59Z"
```

## Date format

For commands that take explicit `--from` / `--to` / `--start` / `--end` / `--due`, use **ISO 8601** with timezone:

| Example | Description |
|---------|-------------|
| `2026-01-15T09:00:00Z` | 9:00 AM UTC |
| `2026-01-15T09:00:00+10:00` | 9:00 AM AEST |
| `2026-01-15T00:00:00Z` | Start of day (midnight UTC) |
| `2026-01-15T23:59:59Z` | End of day |

For "today" / "tomorrow" / "this week", **use the subcommands above instead of computing dates** — `today`/`tomorrow`/`next` are local-timezone-aware and don't rely on the BSD-only `date -v+1d` flag (which breaks on Linux).

If you genuinely need a custom range outside today/tomorrow/next, generate dates like this:
```bash
# An explicit absolute date
START="2026-01-15T09:00:00Z"

# A relative date in the user's local zone via Swift / Python is more portable
# than `date -v+1d`. For most cases, `ekctl next --days N` is simpler.
```

## Common patterns

### Get today's busy events
```bash
ekctl today --calendar work --availability busy
```

### Get the next 3 meetings
```bash
ekctl next --calendar work --count 3
```

### Search across all my calendars
```bash
ekctl today --calendar work,personal --search "1:1"
```

### Create a meeting
```bash
ekctl add event \
  --calendar work \
  --title "Team Standup" \
  --start "2026-01-15T09:00:00Z" \
  --end "2026-01-15T09:30:00Z" \
  --location "Conference Room A" \
  --notes "Weekly sync"
```

### Create a recurring meeting
```bash
ekctl add event \
  --calendar work \
  --title "Weekly 1:1" \
  --start "2026-01-15T14:00:00Z" \
  --end "2026-01-15T14:30:00Z" \
  --recurrence-frequency weekly \
  --recurrence-end-count 12
```

### Create an all-day event
```bash
ekctl add event \
  --calendar personal \
  --title "Vacation Day" \
  --start "2026-01-20T00:00:00Z" \
  --end "2026-01-21T00:00:00Z" \
  --all-day
```

### Add a reminder with due date
```bash
ekctl add reminder \
  --list personal \
  --title "Call the dentist" \
  --due "2026-01-16T10:00:00Z" \
  --priority 1
```

### List incomplete reminders
```bash
ekctl list reminders --list personal --completed false
```

### Complete a reminder
```bash
ekctl complete reminder "REMINDER_ID"
```

### Update an event
```bash
ekctl update event "EVENT_ID" --title "Renamed meeting" --location "New room"
```

### Update a reminder
```bash
ekctl update reminder "REMINDER_ID" --due "2026-01-17T10:00:00Z" --priority 5
```

## Output JSON shape

Events include these fields (since 1.4.0):

```json
{
  "id": "ABC123:DEF456",
  "title": "Team Meeting",
  "calendar": { "id": "...", "title": "Work" },
  "startDate": "2026-01-15T09:00:00+11:00",
  "endDate": "2026-01-15T10:00:00+11:00",
  "location": "Conference Room A",
  "notes": null,
  "url": null,
  "allDay": false,
  "hasAlarms": true,
  "hasRecurrenceRules": false,
  "availability": "busy",
  "attendees": [
    { "name": "Jane Doe", "email": "jane@example.com", "status": "accepted", "role": "required" }
  ]
}
```

Reminders include:

```json
{
  "id": "REM123-456-789",
  "title": "Buy groceries",
  "list": { "id": "...", "title": "Personal" },
  "dueDate": "2026-01-20T17:00:00+11:00",
  "completed": false,
  "priority": 0,
  "notes": null,
  "url": null
}
```

## JSON output handling

ekctl returns JSON by default. For most filtering needs, prefer the built-in flags over `jq` — they're typically clearer and don't require a date / substring round-trip:

| Need | Old way (jq) | New way (built-in) |
|---|---|---|
| Events for today | `--from $TODAY --to $TOMORROW` | `ekctl today --calendar work` |
| Title contains "standup" | `... \| jq '.events[] \| select(.title \| contains("standup"))'` | `--search standup` |
| Only busy events | `... \| jq '.events[] \| select(.availability == "busy")'` | `--availability busy` |
| Multiple calendars | run twice + merge | `--calendar work,personal` |
| CSV export | `... \| jq -r '... \| @csv'` | `--format csv` |
| The next event only | sort + head -n1 | `ekctl next --calendar work` |

`jq` is still the right tool for cross-cutting transformations (e.g., extracting just titles, computing durations, joining with external data). See `scripting-examples.md`.

## Error handling

Check the `status` field in responses:
```json
{
  "status": "error",
  "error": "Calendar not found with ID: invalid-id"
}
```

In CSV format, errors become a single row:
```
error,status
Calendar not found with ID: invalid-id,error
```

In text format:
```
error: Calendar not found with ID: invalid-id
status: error
```

Common errors:
- **Permission denied** — User needs to grant Calendar/Reminders access in System Settings → Privacy & Security.
- **Calendar not found** — Invalid calendar ID or alias. Run `ekctl list calendars` and `ekctl alias list`.
- **Invalid date format** — Must use ISO 8601 with timezone.
- **`--count must be a positive integer`** / **`--days must be a positive integer`** — `next` rejects non-positive values.

## Anti-patterns

- ❌ Computing today/tomorrow with `date -u -v+1d` shell arithmetic — BSD-only, breaks on Linux containers
- ✅ Use `ekctl today` / `ekctl tomorrow` / `ekctl next` instead

- ❌ Post-filtering with `jq '.events[] | select(.title | contains(…))'`
- ✅ Use `--search` — same result, far simpler

- ❌ Filtering by availability with `jq '.events[] | select(.availability == "busy")'`
- ✅ Use `--availability busy` — server-side, also cleaner

- ❌ Building CSV with `jq -r '... | @csv'` hand-mapped column lists
- ✅ Use `--format csv` — picks up new fields automatically, RFC 4180 escaping built in

- ❌ Running `list events` twice to merge two calendars
- ✅ `--calendar work,personal` does it in one call, with `calendar.id` per event so you can still demux

- ❌ Using raw calendar IDs repeatedly without suggesting aliases
- ✅ Help users set up aliases for calendars they use often

- ❌ Ignoring the JSON `status` field
- ✅ Always check `status` and surface errors to the user

- ❌ Listing all events without a date range
- ✅ Use `today` / `tomorrow` / `next`, or sensible explicit `--from`/`--to`

## References

- See `command-reference.md` for complete command and flag documentation
- See `scripting-examples.md` for jq patterns and integration recipes
