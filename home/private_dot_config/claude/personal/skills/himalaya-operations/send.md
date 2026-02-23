# Send Email

Substitute **Email** and **Account flag** from SKILL.md config into the commands and MIME headers below.

## Instructions

1. If the user has not already provided all three, use AskUserQuestion to gather:
   - **To** (recipient email address)
   - **Subject**
   - **Body** (plain text)

2. Construct a raw MIME message using this exact format (no extra blank lines before headers):

   ```
   From: <Email>
   To: <recipient>
   Subject: <subject>
   Content-Type: text/plain; charset=utf-8

   <body>
   ```

3. Pipe the message to himalaya using Bash:

   ```bash
   printf 'From: <Email>\nTo: %s\nSubject: %s\nContent-Type: text/plain; charset=utf-8\n\n%s' "<to>" "<subject>" "<body>" | himalaya message send <Account flag>
   ```

4. Report the result to the user: confirm the email was sent or relay any error from himalaya.
