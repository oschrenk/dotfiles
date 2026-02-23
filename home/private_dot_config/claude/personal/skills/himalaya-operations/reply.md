# Reply to Email

Substitute **Account flag** from SKILL.md config into all commands below.

## Instructions

1. You need the **envelope ID** of the message to reply to. If not known, read `read.md` first to list and identify it.

2. If the user has not provided the reply body, use AskUserQuestion to gather it.

3. Send the reply using Bash:

   ```bash
   himalaya message reply <Account flag> <ID> "<body>"
   ```

   - Use `-A` to reply to all recipients.
   - Use `-f <FOLDER>` if the message is not in INBOX.

4. Report the result to the user: confirm the reply was sent or relay any error from himalaya.
