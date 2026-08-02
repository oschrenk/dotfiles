# Edit a Ticket

```bash
jira issue edit <KEY> --no-input -b "<new description>"
```

Common flags: `-s` summary, `-b` description (body), `-y` priority, `-a` assignee, `-P` parent,
`-l` label (append). Body is Markdown (see SKILL.md gotchas).

- **`-b` replaces the whole description.** There's no in-place patch — read the current description
  first (`jira issue view <KEY> --plain`) if you're amending rather than rewriting.
- **Do NOT pass `--skip-notify`** — 403 without admin rights. Omit it.
- **No `-T`/`--template` on `edit`** (unlike `create` and `comment add`) — `jira issue edit` only
  reads the body from `-b`. Passing `-T` fails with `unknown shorthand flag: 'T'`. For long
  descriptions, heredoc a file's contents into `-b`: `-b "$(cat description.md)"`.

Rewrite description via heredoc:

```bash
jira issue edit <KEY> --no-input -b "$(cat <<'EOF'
## Goal

Rewritten description in **Markdown**.
EOF
)"
```

Verify: `jira issue view <KEY> --plain`.
