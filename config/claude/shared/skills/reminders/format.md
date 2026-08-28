# JSON Format & Detailed Options

## JSON Output

When using `--format json`, items look like:

```json
{
  "externalId": "UUID",
  "isCompleted": false,
  "list": "Task",
  "priority": 0,
  "title": "Reminder text"
}
```

Priority values: 0 = none, 1 = high, 5 = medium, 9 = low.

## show / show-all Options

- `--format json` — JSON output (prefer this for parsing)
- `--only-completed` — show completed items only
- `--include-completed` — include completed alongside incomplete
- `-s, --sort <field>` — sort by: `none`, `creation-date`, `due-date`
- `-o, --sort-order <order>` — `ascending` or `descending`
- `-d, --due-date <date>` — filter to reminders due on this date

## add Options

- `-d, --due-date <date>` — due date (natural language or ISO)
- `-p, --priority <priority>` — `none`, `low`, `medium`, `high`
- `-n, --notes <notes>` — notes to attach
- `--format json` — return JSON confirmation

## edit Options

- `-n, --notes <notes>` — overwrite notes
