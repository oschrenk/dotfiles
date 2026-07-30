# Comment on an MR

Only post when explicitly asked. When posting review findings: one issue per comment/discussion
(so each can be resolved individually), body starting with a `##` heading that summarizes it.
Verify by fetching discussions afterward (see `view.md`).

## Top-level comment

```bash
glab mr note 1234 -m "$(cat /path/to/comment.md)"
```

## Inline diff comment (positioned discussion)

Anchors the comment to a file+line in the diff. Two steps: get the diff SHAs, then POST a
discussion with a `position`.

```bash
glab api "projects/:fullpath/merge_requests/1234/versions" |
  jq '.[0] | {base_commit_sha, start_commit_sha, head_commit_sha}'
```

Write the payload to a scratchpad file:

```json
{
  "body": "## Summary of the issue\n\nDetails...",
  "position": {
    "position_type": "text",
    "base_sha": "<base_commit_sha>",
    "start_sha": "<start_commit_sha>",
    "head_sha": "<head_commit_sha>",
    "new_path": "src/main/kotlin/Foo.kt",
    "new_line": 42
  }
}
```

```bash
glab api --method POST "projects/:fullpath/merge_requests/1234/discussions" --input payload.json
```

- **Added line** → `new_path` + `new_line` (line number in the new file).
- **Deleted line** → `old_path` + `old_line` instead.
- **Unchanged (context) line** → both `old_path`+`old_line` and `new_path`+`new_line`.
- A 400 about `line_code` means the line isn't part of the diff, or old/new sides don't match —
  re-check against the actual diff hunks.

## Reply to a discussion

```bash
glab api --method POST \
  "projects/:fullpath/merge_requests/1234/discussions/<discussion_id>/notes" \
  --raw-field "body=$(cat /path/to/reply.md)"
```

## Resolve / unresolve

```bash
glab mr note 1234 --resolve <note-id>      # note ID (numeric), not discussion ID
glab mr note 1234 --unresolve <note-id>
```

Or by discussion ID (the hash from the discussions listing):

```bash
glab api --method PUT \
  "projects/:fullpath/merge_requests/1234/discussions/<discussion_id>" -f resolved=true
```
