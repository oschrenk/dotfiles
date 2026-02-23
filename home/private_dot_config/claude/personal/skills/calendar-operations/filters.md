# Filtering & Output Options

All event-based commands (`today`, `on`, `next`, `hours`) support these filters.

## Calendar Filtering

- `--select-calendar-ids <ids>` - Select by calendar UUID
- `--ignore-calendar-ids <ids>` - Ignore by calendar UUID
- `--select-calendar-labels <labels>` - Select by name (comma-separated)
- `--ignore-calendar-labels <labels>` - Ignore by name (comma-separated)
- `--select-calendar-types <types>` - Types: local, caldav, exchange, subscription, birthday
- `--ignore-calendar-types <types>` - Ignore specific types
- `--select-calendar-sources <sources>` - Select by source
- `--ignore-calendar-sources <sources>` - Ignore by source

## Event Filtering

- `--ignore-all-day-events` - Skip all-day events
- `--select-all-day-events` - Only all-day events
- `--ignore-title <pattern>` - Ignore titles matching pattern
- `--select-title <pattern>` - Select titles matching pattern
- `--min-num-attendees <n>` - Minimum attendees (inclusive)
- `--max-num-attendees <n>` - Maximum attendees (inclusive)
- `--min-duration <m>` - Minimum duration in minutes (inclusive)
- `--max-duration <m>` - Maximum duration in minutes (inclusive)

## Tag & Service Filtering

- `--ignore-tags <tags>` - Ignore events with tags (e.g., 'tag:timeblock')
- `--select-tags <tags>` - Select events with tags
- `--ignore-services <services>` - Ignore events with services
- `--select-services <services>` - Select events with services

## Sorting

- `--sort-by <field[:direction]>` - Sort by field (asc/desc)
- Available fields: id, calendar.id, calendar.type, calendar.label, title.full, schedule.start.at, schedule.end.at, location, meeting.organizer

## Custom Output

- `--template-path <path>` - Custom template for output
- `--format plain` - Plain text output (calendars command only)

## JSON Output Schema

```json
{
  "title": {"label": "Event Title", "icon": "...", "full": "... Event Title"},
  "schedule": {
    "start": {"at": "2026-04-03T10:00:00", "in": "..."},
    "end": {"at": "2026-04-03T11:00:00", "in": "..."},
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
