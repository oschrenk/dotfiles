# Link / Unlink Tickets

```bash
jira issue link <FIRST> <SECOND> <TYPE>
```

Common types: `Blocks`, `Duplicate`, `Relates`, `Cloners`.

## Direction — the trap

The link reads **`<FIRST> <verb> <SECOND>`**. For the `Blocks` type the **first arg is the
blocker**.

So to record "**A is blocked by B**" (B blocks A), put the **blocker first**:

```bash
jira issue link B A Blocks     # => B blocks A;  A "is blocked by" B
```

Concretely: to make DEV-3895 block DEV-4192 (4192 requires 3895):

```bash
jira issue link DEV-3895 DEV-4192 Blocks
```

Verified with jira-cli 1.7.0 on 2026-10-04: `link DEV-4192 DEV-3895 Blocks` made DEV-4192 block
DEV-3895, the reverse of the intent; `link DEV-3895 DEV-4192 Blocks` gave the right result. An earlier
version of this file said the blocker goes second — do not trust that.

**Always verify direction** — view both tickets and confirm they read correctly:

```bash
jira issue view DEV-3895 --plain | grep -iA6 "Linked Issues"   # expect: BLOCKS DEV-4192
jira issue view DEV-4192 --plain | grep -iA6 "Linked Issues"   # expect: IS BLOCKED BY DEV-3895
```

The `--plain` "Linked Issues" section is grouped by the link phrase (`IS BLOCKED BY`, `BLOCKS`, …),
so it tells you the direction directly.

## Unlink

```bash
jira issue unlink <FIRST> <SECOND>
```

If you linked backwards: `unlink` the pair (order doesn't matter for removal), then re-`link` with the
blocker as the first arg.
