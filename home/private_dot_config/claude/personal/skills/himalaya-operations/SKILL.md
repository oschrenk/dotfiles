---
name: himalaya-operations
description: Manage email via himalaya.
user-invocable: true
---

# Himalaya Operations

## Config

- **Email:** `oliver.schrenk@gmail.com`
- **Account flag:** `-a personal`
- **Global flags:** `--quiet`

Use these values in all himalaya commands and MIME headers. Global flags go right after `himalaya`, e.g. `himalaya --quiet envelope list -a personal`.

## Routing

- **User wants to send an email** → Read `send.md` in this skill directory, then follow its instructions.
- **User wants to read/list emails** → Read `read.md` in this skill directory, then follow its instructions.
- **User wants to reply to an email** → Read `reply.md` in this skill directory, then follow its instructions.

## Rules

- Plain text only for sending. No attachments, no HTML.
- Do not add CC or BCC unless the user explicitly asks.
