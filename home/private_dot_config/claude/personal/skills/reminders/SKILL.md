---
name: reminders
description: Manage macOS Reminders from the command line. List, add, complete, edit, and delete reminders. Use when the user asks about their todos, tasks, reminders, or to-do lists.
---

# Reminders

Manage macOS Reminders using the `reminders` CLI (`/opt/homebrew/bin/reminders`).

## Available Lists

Query current lists with:
```bash
/opt/homebrew/bin/reminders show-lists
```

## Command Reference

### Show reminders on a list

```bash
/opt/homebrew/bin/reminders show <list-name> [options]
```

Options:
- `--format json` — JSON output (prefer this for parsing)
- `--only-completed` — show completed items only
- `--include-completed` — include completed items alongside incomplete
- `-s, --sort <field>` — sort by: `none`, `creation-date`, `due-date`
- `-o, --sort-order <order>` — `ascending` or `descending`
- `-d, --due-date <date>` — filter to reminders due on this date

### Show all reminders across every list

```bash
/opt/homebrew/bin/reminders show-all [options]
```

Same options as `show` except no list name argument.

### Add a reminder

```bash
/opt/homebrew/bin/reminders add <list-name> <reminder> [options]
```

Options:
- `-d, --due-date <date>` — due date (natural language: "tomorrow 9am", or ISO: "2025-04-03")
- `-p, --priority <priority>` — `none`, `low`, `medium`, `high`
- `-n, --notes <notes>` — notes to attach
- `--format json` — return JSON confirmation

### Complete a reminder

```bash
/opt/homebrew/bin/reminders complete <list-name> <index>
```

The `<index>` is the 0-based position from `show` output.

### Uncomplete a reminder

```bash
/opt/homebrew/bin/reminders uncomplete <list-name> <index>
```

### Edit a reminder

```bash
/opt/homebrew/bin/reminders edit <list-name> <index> [new-text] [options]
```

Options:
- `-n, --notes <notes>` — overwrite notes

### Delete a reminder

```bash
/opt/homebrew/bin/reminders delete <list-name> <index>
```

### Create a new list

```bash
/opt/homebrew/bin/reminders new-list <list-name>
```

## JSON Output Format

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

## Command Mapping

Map user queries to the appropriate command:

| User Query | Command |
|------------|---------|
| "What's on my todo list?" | `show Task` |
| "Show my shopping list" | `show Shopping` |
| "Show all my reminders" | `show-all` |
| "Add milk to shopping" | `add Shopping "Buy milk"` |
| "Remind me to call dentist tomorrow" | `add Task "Call dentist" --due-date "tomorrow"` |
| "Mark the first task as done" | `complete Task 0` |
| "Delete the third shopping item" | `delete Shopping 2` |
| "What lists do I have?" | `show-lists` |
| "Show completed tasks" | `show Task --only-completed` |
| "What's due today?" | `show-all --due-date today` |

## Instructions

1. Always use `--format json` when reading reminders so you can parse and present them cleanly.
2. When showing reminders, format them as a numbered list with title, due date (if any), and priority (if set). Include the list name when showing results from `show-all`.
3. When adding reminders, confirm the action and show what was added.
4. When completing or deleting, first `show` the list with `--format json` to confirm the correct index, then perform the action. Tell the user which item was affected.
5. If the user doesn't specify a list, ask which list to use. Show available lists to help them choose.
6. Quote list names that contain spaces or special characters (e.g., `"Liza & Oliver"`).
7. Handle errors gracefully — if a list doesn't exist or index is out of range, explain what went wrong.
