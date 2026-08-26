# List Tickets

## Steps

1. Get the current user:
   ```bash
   jira me
   ```

2. List tickets assigned to the current user (default status: "In Progress"):
   ```bash
   jira issue list --plain --no-headers -a"$(jira me)" -s"In Progress"
   ```
   Override status with `--status` argument (e.g. `/jira-operations --status "To Do"`).

3. For each ticket key, fetch the full view:
   ```bash
   jira issue view <KEY> --plain
   ```

4. Extract from each ticket view:
   - **Description**: text between `Description` and `View this issue` lines
   - **Comment count**: the `N comments` value from the header line (first line of output)

5. Present results sorted by ticket key descending (newest first):
   ```
   **DEV-1234** — Ticket title (2 comments)
   > Brief description (1-2 sentences).

   **DEV-5678** — Another ticket
   > Another description.
   ```
   Flag tickets with comments so they stand out.

## Arguments

| Argument | Meaning | Example |
|----------|---------|---------|
| `--status <status>` | Filter by status other than "In Progress" | `/jira-operations --status "To Do"` |
| `--comments` | Also show comment content | `/jira-operations --comments` |

When `--comments` is specified, for each ticket that has comments, also run:
```bash
jira issue view <KEY> --plain --comments <N>
```
Extract and display comment author, date, and content.
