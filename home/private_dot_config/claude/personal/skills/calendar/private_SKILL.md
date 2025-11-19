---
name: calendar
description: Fetch and display today's calendar events from Apple Calendar. Use when the user asks about today's schedule, meetings, appointments, or what's on their calendar today.
---

# Calendar

This skill fetches events from Apple Calendar using the `plan` CLI tool.

## Instructions

When the user asks about today's calendar events, meetings, or schedule:

1. Run the `plan today` command to fetch events:
   ```bash
   /opt/homebrew/bin/plan today
   ```

2. The output is JSON format with event details including:
   - `title.label`: Event title
   - `schedule.start.at`: Start time
   - `schedule.end.at`: End time
   - `schedule.all_day`: Whether it's an all-day event
   - `calendar.label`: Calendar name
   - `location`: Event location (if present)
   - `meeting.attendees`: List of attendees

3. Parse the JSON and present the events in a user-friendly format, sorted by start time.

4. Common filters you can apply:
   - `--ignore-calendar-types birthday`: Skip birthday events
   - `--ignore-all-day-events`: Skip all-day events
   - `--select-calendar-labels "Work"`: Only show events from specific calendars
   - `--min-duration 15`: Only events longer than 15 minutes

## Examples

**Basic usage:**
```bash
/opt/homebrew/bin/plan today
```

**Filter out birthdays:**
```bash
/opt/homebrew/bin/plan today --ignore-calendar-types birthday
```

**Show only work calendar:**
```bash
/opt/homebrew/bin/plan today --select-calendar-labels "Work"
```

**Show only meetings (with attendees):**
```bash
/opt/homebrew/bin/plan today --min-num-attendees 1
```
