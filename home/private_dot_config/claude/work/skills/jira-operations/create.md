# Create a Ticket

```bash
jira issue create -t <Type> -s "<summary>" -y <Priority> --no-input -b "<body>"
```

- `-t` type (e.g. `Task`, `Bug`, `Sub-task`, `Story`), `-s` summary, `-y` priority, `-a` assignee,
  `-l` label (repeatable), `-P` parent.
- **Sub-tasks require `-P <PARENT-KEY>`.**
- Body is Markdown (see SKILL.md gotchas). For long bodies, write a file and use `-T <file>`
  instead of `-b`.

Long body via heredoc:

```bash
jira issue create -t Task -s "Short summary" -y Medium --no-input -b "$(cat <<'EOF'
## Goal

Body in **Markdown**.

1. first step
2. second step
EOF
)"
```

The command prints the new key + URL. If the user asked, self-assign with `-a "$(jira me)"`.
