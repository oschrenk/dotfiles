# Link / Unlink Tickets

```bash
jira issue link <INWARD> <OUTWARD> <TYPE>
```

Common types: `Blocks`, `Duplicate`, `Relates`, `Cloners`.

## Direction — the trap

The link phrase reads **`<OUTWARD> <verb> <INWARD>`**, i.e. the **first arg is the passive/inward
side**, the **second arg is the active side**. For the `Blocks` type the second (outward) arg is the
one that *blocks*.

So to record "**A is blocked by B**" (B blocks A), put the **blocker second**:

```bash
jira issue link A B Blocks     # => B blocks A;  A "is blocked by" B
```

Concretely: to make DEV-3766 block DEV-3472 (3472 is blocked by 3766):

```bash
jira issue link DEV-3472 DEV-3766 Blocks
```

**Always verify direction** — view the blocker and confirm it reads correctly:

```bash
jira issue view DEV-3472 --plain | grep -iA6 "Linked Issues"   # expect: IS BLOCKED BY DEV-3766
```

The `--plain` "Linked Issues" section is grouped by the link phrase (`IS BLOCKED BY`, `BLOCKS`, …),
so it tells you the direction directly.

## Unlink

```bash
jira issue unlink <INWARD> <OUTWARD>
```

If you linked backwards: `unlink` the pair (order doesn't matter for removal), then re-`link` with the
blocker as the second arg.
