---
name: jira-operations
description: Manage Jira issues via the jira CLI. View, list, inspect, create, comment on, edit, and link tickets.
user-invocable: true
---

# Jira Operations

Manage Jira issues using the `jira` CLI (on your PATH — run `jira`, don't hardcode a path; it may be
homebrew, nix, etc.).

## Command Mapping

| User Query | Route |
|------------|-------|
| "What are my tickets?" / "Show my to-do items" | `list.md` |
| "Show DEV-3046" / "What comments are on DEV-3046?" | `view.md` |
| "Create a ticket / sub-task" | `create.md` |
| "Comment on DEV-3046" | `comment.md` |
| "Change the description / summary / priority" | `edit.md` |
| "Link these tickets" / "mark X blocked by Y" | `link.md` |

## Routing

Read the matching file in this skill directory, then follow it. Only read the file(s) you need.

- **List tickets** → `list.md`
- **View a specific ticket** → `view.md`
- **Create a ticket** → `create.md`
- **Add a comment** → `comment.md`
- **Edit description / summary / fields** → `edit.md`
- **Link / unlink tickets** → `link.md`

## Prerequisites

- `jira` CLI on your PATH (verify with `command -v jira`)
- Config at `~/.config/.jira/.config.yml`

## Shared gotchas (apply to all write operations)

- **Markdown.** The CLI converts Markdown → ADF (Jira Cloud's format), same as pasting into the web
  editor: `##` headings, `-` bullets, `1.` ordered lists, `` `code` ``, `**bold**`. Do NOT use Jira
  wiki markup (`h2.`, `{{}}`, `*bold*`) — it converts inconsistently (`*x*` → italic not bold,
  headings swallow the following line, `*`/`#` lists don't form). Verified via `jira issue view <KEY> --raw`.
- **Non-interactive.** Always pass `--no-input` on create/edit/comment so the CLI never blocks on a prompt.
- **Multi-line bodies:** heredoc into the body arg, or write a file and use `-T <file>` (template).
  `-T` avoids all shell-quoting pain — prefer it for anything long.
- **`--skip-notify` needs admin rights** — returns `403 Forbidden` for normal users. Omit it.
- **Verify writes** by viewing the ticket afterward (`jira issue view <KEY> --plain`).
