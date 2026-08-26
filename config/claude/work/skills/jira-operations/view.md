# View a Specific Ticket

When a ticket key is provided (e.g. `/jira-operations DEV-3046`):

## Steps

1. Fetch the ticket:
   ```bash
   jira issue view <KEY> --plain
   ```

2. Show the full description.

3. If the ticket has comments (check the `N comments` value in the header line), fetch them:
   ```bash
   jira issue view <KEY> --plain --comments <N>
   ```
   Display each comment with author, date, and content.
