# Create or Update an MR

## Create

```bash
glab mr create --fill --assignee oliver.schrenk --yes
```

- **Always self-assign** (`--assignee oliver.schrenk`) — standing rule.
- `--fill` takes title/description from commits and pushes the branch; `--yes` skips prompts.
- Explicit title/description instead of `--fill`:

```bash
glab mr create -t "<title>" -d "$(cat /path/to/description.md)" --assignee oliver.schrenk --yes
```

- Target branch defaults to the project default (`production` on timewax/backend);
  override with `-b <branch>` for stacked MRs.
- `--draft` for work in progress; `--reviewer <username>` to request review.
- Write multi-line descriptions to a scratchpad file first — don't fight shell quoting inline.

## Update

```bash
glab mr update 1234 -t "<new title>"
glab mr update 1234 -d "$(cat /path/to/description.md)"
glab mr update 1234 --ready            # remove draft status; --draft to re-mark
```
