# List Merge Requests

```bash
glab mr list --assignee=@me          # my MRs (open by default)
glab mr list --reviewer=@me          # waiting on my review
glab mr list --author=<username>
glab mr list --draft                 # or --not-draft
glab mr list -M                      # merged; -A all, -c closed
glab mr list --target-branch production
```

- Combine with `-F json` for parseable output, `-P <n>` / `-p <n>` for paging.
- Filter by label: `--label <name>`, exclude with `--not-label <name>`.
- Search in title/description: `--search "<text>"`.
