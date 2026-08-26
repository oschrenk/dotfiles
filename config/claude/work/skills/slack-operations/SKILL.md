---
name: slack-operations
description: Send Slack messages from the terminal via the `slack` fish function — post text now or scheduled for a specific time, ping a channel with an MR review request, list and cancel queued messages. Triggers on "post this to #channel", "ask backend to review my MR", "send that at 9am tomorrow", "what Slack messages are scheduled", "cancel that scheduled message".
user-invocable: true
---

# Slack Operations

Everything goes through the `slack` fish **function** at
`~/.config/fish/functions/slack.fish`. It is self-contained: it talks to the Slack web API
with `curl` and shells out to nothing. It replaced a `slack-cli` binary that used to own the
same name, so ignore any memory of a `slack send --kind` binary — this function *is* `slack`
now.

Because it's a fish function, it does not exist in `zsh`/`sh`. From any non-fish shell
(including the Bash tool) run it as `fish -c 'slack ...'`, or put a multi-command script in a
file and run `fish script.fish` to avoid nested-quoting pain.

## Command Mapping

| User Query | Command |
|------------|---------|
| "post this to #backend" | `slack send "..."` |
| "send it at 9am tomorrow" | `slack send -a "tomorrow 09:00" "..."` |
| "ask for review on my MR" | `slack review` |
| "ping backend about it tomorrow morning" | `slack review -a "tomorrow 09:00"` |
| "what's scheduled?" / "did that send?" | `slack list` |
| "cancel that scheduled message" | `slack cancel <ID>` |

## Writes need intent

- **Never post unless the user asked for that specific send.** A Slack message to a shared
  channel is public and cannot be unsent.
- **Dry-run first.** `--dry-run` / `-n` prints the exact JSON payload and calls nothing. Use
  it to confirm channel, time, and body, then run for real.
- **Confirm the resolved time.** `--at` accepts vague input like `"tomorrow 01:00"`, and a
  wrong day is easy. The function echoes the absolute time it resolved (`→ #backend at Fri 14
  Aug 01:00`) — repeat that back to the user before or right after sending.
- **The default channel is `#backend`.** Every subcommand that posts falls back to it when
  `-c` is omitted. Never rely on that default when the user named a different channel.

## Subcommands

Bare `slack` and `slack help` print usage and post nothing — safe to run.

### `slack send [-c CHANNEL] [-k KIND] [-a WHEN] [-n] MESSAGE`

```fish
slack send "deploy is done"
slack send -c '#dev' -a "tomorrow 08:00" "standup in 15"
slack send -k block '[{"type":"section","text":{"type":"mrkdwn","text":"hi"}}]'
```

- `-k/--kind` is `text` (default), `block`, or `attachment`. For `block` and `attachment` the
  MESSAGE must be valid JSON; a bare object is wrapped into the array Slack requires.
- Invalid JSON, an unknown kind, and a missing message each fail with exit 1 before any HTTP
  call happens.

### `slack review [MR] [-c CHANNEL] [-a WHEN] [-n]`

Posts exactly this, built from a GitLab MR:

```
Please review

<MR title>
<MR web URL>
```

```fish
slack review                          # current branch's MR → #backend, now
slack review --at "tomorrow 09:00"    # Slack holds it, posts at 09:00
slack review 2899 -c '#dev' -a 14:30  # explicit MR iid, channel, today 14:30
```

The MR argument is optional and goes to `glab mr view`, so with no argument it resolves the
current branch's MR — which means it must run inside the repo. No MR found exits 1.

### `slack list` / `slack cancel ID`

```fish
slack list                # id, channel id, local time, first 56 chars of text
slack cancel Q0BQ07ECBN2  # looks up the id's channel, then deletes it
```

`cancel` takes only the id — it finds the channel from the queue itself.

## Scheduled messages are invisible in the Slack app

Messages created by `chat.scheduleMessage` do **not** appear in the Slack client's
**Scheduled** list, or in the "scheduled message" banner above a channel's composer. They are
genuinely queued — `slack list` reads Slack's own record of the queue — but the user has no
UI to view, edit, or cancel them. Consequences to honour:

- Always surface the `scheduled_message_id` after scheduling. It is the only cancel handle,
  and `slack send`/`slack review` print it with the ready-made `slack cancel <id>` command.
- If the user wants something they can see and edit inside Slack, say so plainly and suggest
  they schedule it in the app instead — then offer to cancel the API-scheduled one.
- Don't claim a scheduled message "isn't there" because the app doesn't show it. Check
  `slack list`.

## Timing rules

- `--at` is parsed by GNU `date -d` in the machine's local timezone (currently Guatemala,
  `CST -0600`). Accepts `"09:00"`, `"tomorrow 09:00"`, `"2026-08-20 14:30"`.
- A past time is refused rather than silently rolled forward to tomorrow.
- Slack itself refuses a `post_at` more than 120 days out.
- For another timezone, pass an explicit offset — `--at "2026-08-14 01:00 -0600"` — rather
  than doing mental arithmetic.

## Gotchas

- **`SLACK_TOKEN` must be exported.** A `xoxp-` user token, so messages post as the user and
  not as a bot. Every subcommand fails fast with a clear message if it's unset.
- **Channel names cannot be resolved to ids.** The token lacks the scope for
  `conversations.info`, so `slack list` shows raw channel ids like `C059T3QQR5W`. Passing
  `#backend` *to* a send works fine — Slack resolves names server-side.
- **`\n` is literal inside fish double quotes.** `slack send "a\nb"` posts a literal
  backslash-n. Fish only expands `$var`, `\"`, `\$`, `\\` in double quotes. Build multi-line
  bodies with `printf`.
- **Command substitution splits on newlines.** Fish turns each line into a separate argument,
  and `send` takes exactly one message argument. Pipe through `string collect`:

  ```fish
  slack send (printf 'line one\n\nline three' | string collect)
  ```

- **`\n` in a dry-run payload is correct.** JSON has no other way to encode a newline inside a
  string; Slack decodes it to a real line break. Don't "fix" it.
- **Verify writes.** After scheduling or cancelling, run `slack list` — don't trust the send
  response alone.
