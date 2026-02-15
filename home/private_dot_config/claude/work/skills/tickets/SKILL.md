---
name: tickets
description: View your current Jira tickets. Lists in-progress issues assigned to you with descriptions and comment counts. Use when the user asks about their tickets, current work, or Jira issues.
---

# Jira Tickets

This skill shows your current in-progress Jira tickets using the `jira` CLI (jira-cli).

## Prerequisites

- `jira` CLI installed at `/opt/homebrew/bin/jira`
- Configuration at `~/.config/.jira/.config.yml`

## Default Behavior

When invoked without arguments, list all in-progress tickets assigned to the current user with their descriptions and comment counts.

## Steps

1. Get the current user:
   ```bash
   jira me
   ```

2. List in-progress tickets:
   ```bash
   jira issue list --plain --no-headers -a"$(jira me)" -s"In Progress"
   ```

3. For each ticket key, fetch the full view:
   ```bash
   jira issue view <KEY> --plain
   ```

4. Extract from each ticket view:
   - **Description**: text between `Description` and `View this issue` lines
   - **Comment count**: the `N comments` value from the header line (first line of output)

5. Present a summary table with:
   - Ticket key
   - Title
   - Description (condensed to 1-2 sentences)
   - Comment count (flag tickets that have comments)

## Arguments

The user may provide arguments to customize the query:

| Argument | Meaning | Example |
|----------|---------|---------|
| A ticket key | View full details for that specific ticket | `/tickets DEV-3046` |
| `--status <status>` | Filter by status other than "In Progress" | `/tickets --status "To Do"` |
| `--comments` | Also show comment content for tickets that have comments | `/tickets --comments` |

### Viewing a specific ticket

When a ticket key is provided:
```bash
jira issue view <KEY> --plain
```
Show the full description and all comments (use `--comments <N>` where N is the comment count).

### Viewing comments

When `--comments` is specified, for each ticket that has comments, also run:
```bash
jira issue view <KEY> --plain --comments <N>
```
Extract and display comment author, date, and content.

## Output Format

Present results clearly:

```
**DEV-1234** — Ticket title (2 comments)
> Brief description here.

**DEV-5678** — Another ticket
> Another description.
```

Flag tickets with comments so they stand out. Sort by ticket key descending (newest first).
