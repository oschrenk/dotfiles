# Calendar Hours

This skill calculates total worked hours from last week using the `plan` CLI tool.

## Instructions

When the user asks about last week's worked hours or time tracking:

1. Calculate the dates for last week (Monday through Friday)
2. For each day, run: `/opt/homebrew/bin/plan hours --select-title Timewax YYYY-MM-DD`
3. Parse the output which is in format: `🕐 Timewax: H.MM`
4. Sum up all the hours from the 5 weekdays
5. Present the results showing:
   - Hours per day
   - Total hours for the week

## Example

For the week of November 18-22, 2025:

```bash
/opt/homebrew/bin/plan hours --select-title Timewax 2025-11-18
/opt/homebrew/bin/plan hours --select-title Timewax 2025-11-19
/opt/homebrew/bin/plan hours --select-title Timewax 2025-11-20
/opt/homebrew/bin/plan hours --select-title Timewax 2025-11-21
/opt/homebrew/bin/plan hours --select-title Timewax 2025-11-22
```

## Date Calculation

"Last week" means the most recent complete Monday-Friday work week:
- If today is Monday-Thursday: last week = 2 weeks ago
- If today is Friday-Sunday: last week = 1 week ago

## Parsing

The output format is: `🕐 Timewax: 6.50`
Extract the numeric value after the colon and sum them up.

## Customization

You can filter by different title patterns using `--select-title`:
- `--select-title Timewax`: Only events with "Timewax" in title
- `--select-title "meeting"`: Events with "meeting" in title
- No filter: all events
