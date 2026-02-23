# Read Emails

Substitute **Account flag** from SKILL.md config into all commands below.

## List envelopes (inbox overview)

```bash
himalaya envelope list <Account flag> -s 20
```

- Default page size is set to 20. Use `-s <NUMBER>` to change.
- Use `-f <FOLDER>` to list a different folder (default: `INBOX`).
- Use `-p <NUMBER>` for pagination.
- Supports filter queries: `from <pattern>`, `subject <pattern>`, `body <pattern>`, `date <yyyy-mm-dd>`, `before <yyyy-mm-dd>`, `after <yyyy-mm-dd>`, `flag <flag>`, combinable with `and`, `or`, `not`.
- Supports sort queries: `order by date desc`, `order by subject asc`, etc.

Example — recent unread emails:

```bash
himalaya envelope list <Account flag> flag not-seen
```

## Read a message

Once you have an envelope ID from the list above:

```bash
himalaya message read <Account flag> <ID>
```

- Use `--preview` to read without marking the message as seen.
- Use `--no-headers` to show only the body.
- Use `-H From -H Subject -H Date` to show specific headers.
