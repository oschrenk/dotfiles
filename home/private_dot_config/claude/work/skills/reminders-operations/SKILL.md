---
name: reminders-operations
description: Manage macOS Reminders from the command line.
user-invocable: true
---

# Reminders Operations

Manage macOS Reminders using the `reminders` CLI at `/opt/homebrew/bin/reminders`.

## Command Mapping

| User Query | Command |
|------------|---------|
| "What's on my todo list?" | `reminders show Task --format json` |
| "Show my shopping list" | `reminders show Shopping --format json` |
| "Show all my reminders" | `reminders show-all --format json` |
| "Add milk to shopping" | `reminders add Shopping "Buy milk"` |
| "Remind me to call dentist tomorrow" | `reminders add Task "Call dentist" -d "tomorrow"` |
| "Mark the first task as done" | `reminders complete Task 0` |
| "Delete the third shopping item" | `reminders delete Shopping 2` |
| "What lists do I have?" | `reminders show-lists` |
| "Show completed tasks" | `reminders show Task --only-completed --format json` |
| "What's due today?" | `reminders show-all -d today --format json` |

## Commands

### show-lists

```bash
/opt/homebrew/bin/reminders show-lists
```

### show \<list\> / show-all

```bash
/opt/homebrew/bin/reminders show <list-name> --format json
/opt/homebrew/bin/reminders show-all --format json
```

Common options: `--only-completed`, `--include-completed`, `-s due-date`, `-o ascending`, `-d today`.

### add \<list\> \<reminder\>

```bash
/opt/homebrew/bin/reminders add <list-name> <reminder> [-d <date>] [-p <priority>] [-n <notes>]
```

Date supports natural language (`"tomorrow 9am"`) and ISO (`"2026-04-03"`). Priority: `none`, `low`, `medium`, `high`.

### complete / uncomplete \<list\> \<index\>

```bash
/opt/homebrew/bin/reminders complete <list-name> <index>
/opt/homebrew/bin/reminders uncomplete <list-name> <index>
```

Index is 0-based from `show` output.

### edit \<list\> \<index\> [new-text]

```bash
/opt/homebrew/bin/reminders edit <list-name> <index> [new-text] [-n <notes>]
```

### delete \<list\> \<index\>

```bash
/opt/homebrew/bin/reminders delete <list-name> <index>
```

### new-list \<list-name\>

```bash
/opt/homebrew/bin/reminders new-list <list-name>
```

## Rules

1. Always use `--format json` when reading reminders for parsing. For JSON schema details, read `format.md` in this skill directory.
2. Present reminders as a numbered list with title, due date (if any), and priority (if set).
3. When completing or deleting, first `show` the list to confirm the correct index, then perform the action.
4. If the user doesn't specify a list, ask which list to use — show available lists.
5. Quote list names with spaces or special characters (e.g., `"John & Jane"`).
