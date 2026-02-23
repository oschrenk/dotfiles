---
name: jira-operations
description: Manage Jira issues via the jira CLI. View, list, and inspect tickets with comments.
user-invocable: true
---

# Jira Operations

Manage Jira issues using the `jira` CLI at `/opt/homebrew/bin/jira`.

## Command Mapping

| User Query | Action |
|------------|--------|
| "What are my tickets?" | List in-progress issues |
| "Show my to-do items" | List issues with `--status "To Do"` |
| "Show DEV-3046" | View a specific ticket |
| "What comments are on DEV-3046?" | View a ticket with comments |

## Routing

- **User wants to list tickets** → Read `list.md` in this skill directory, then follow its instructions.
- **User wants to view a specific ticket** → Read `view.md` in this skill directory, then follow its instructions.

## Prerequisites

- `jira` CLI installed at `/opt/homebrew/bin/jira`
- Configuration at `~/.config/.jira/.config.yml`
