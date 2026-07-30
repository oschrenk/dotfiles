# Add a Comment

```bash
jira issue comment add <KEY> "<body>" --no-input
```

- Body is Markdown (see SKILL.md gotchas).
- Long comment: heredoc into the body arg, or `-T <file>` (template file) to dodge shell quoting.
- `--internal` marks the comment internal (not visible to customers) — only when asked.

Long comment via heredoc:

```bash
jira issue comment add <KEY> "$(cat <<'EOF'
Findings:

- point one
- point two
EOF
)" --no-input
```
