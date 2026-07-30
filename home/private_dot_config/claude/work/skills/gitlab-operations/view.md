# View an MR, its Diff, and its Discussions

## Metadata

```bash
glab mr view 1234                    # title, description, state, approvals
glab mr view 1234 -F json            # parseable (iid, sha, pipeline, assignees, ...)
glab mr view 1234 -c                 # include comments/activities
glab mr view 1234 --unresolved       # only unresolved discussions
```

## Diff

```bash
glab mr diff 1234
```

- Large diffs (>~1000 lines): save to a scratchpad file first, then read in chunks.
- Per-file diffs without pulling everything:

```bash
glab api "projects/:fullpath/merge_requests/1234/diffs" --paginate |
  jq -r '.[].new_path'                                   # list changed files
glab api "projects/:fullpath/merge_requests/1234/diffs" --paginate |
  jq -r '.[] | select(.new_path == "src/Foo.kt") | .diff'
```

## Discussions (threaded, with resolved state)

Prefer the discussions endpoint over `/notes` — it gives thread structure, per-note IDs,
resolved state, and diff positions, which you need to reply or resolve (see `comment.md`).

```bash
glab api "projects/:fullpath/merge_requests/1234/discussions" --paginate |
  jq '[.[] | select(.notes[0].system | not)] | .[] |
    {discussion: .id, resolved: .notes[0].resolved,
     notes: [.notes[] | {id, author: .author.username, body, file: .position.new_path, line: .position.new_line}]}'
```

- `select(.notes[0].system | not)` drops system activity (pushes, label changes).
- `.position` is null for top-level (non-diff) comments.
