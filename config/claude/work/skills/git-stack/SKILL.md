---
name: git-stack
description: "Use when user asks about managing stacked git branches, rebasing stacks, navigating commits/branches, syncing with remote, or amending commits in a stack."
user-invocable: true
---

# git-stack

`git-stack` manages stacked branches — series of branches built on top of each other, ending on a protected branch (e.g. `main`). It handles automatic rebasing to keep the whole stack consistent.

## Orientation

Visualize the current stack:

```bash
git stack
# or with commits shown:
git stack --show-commits unprotected
```

See all branch stacks:

```bash
git stack --stack all
```

Check which branches are protected:

```bash
git stack --protected
```

## Core Concepts

- **Protected branch**: A branch (e.g. `main`, `master`) that git-stack won't rebase. Set via `stack.protected-branch` in git config or with `git stack --protect <pattern>`.
- **Stack**: A series of commits/branches from a protected branch up to HEAD (or beyond).
- **Fixup commits**: Commits prefixed with `fixup!` or `squash!` that target another commit. git-stack can auto-move or squash them with `--fixup`.

## Viewing Stacks

| Goal | Command |
|------|---------|
| Show current stack | `git stack --stack current` |
| Show current stack (branches only) | `git stack --stack current --show-commits none` |
| Show all stacks | `git stack --stack all` |
| Show with commit details | `git stack --show-commits unprotected` |
| Show dependents too | `git stack --stack dependents` |
| List format (no graph) | `git stack --format list` |

## Rebasing & Syncing

**Rebase the current stack onto its base:**

```bash
git stack --rebase --stack current
```

**Pull the parent branch and rebase onto it:**

```bash
git stack --pull --stack current
```

**Sync all local branches with remote** (fetch + rebase):

```bash
git stack sync
```

**Push all ready branches** (pushes one level at a time — run repeatedly for deep stacks):

```bash
git stack --push --stack current
```

**Rebase + squash fixup commits:**

```bash
git stack --rebase --fixup squash --stack current
```

**Dry-run any operation:**

```bash
git stack --rebase --stack current -n
git stack sync -n
```

**Scope with `--stack`:** Always use `--stack current` to limit operations to the current stack. Other values: `dependents`, `descendants`, `all`.

## Navigating the Stack

Move between commits/branches in the stack:

```bash
git stack next          # move to next descendant commit
git stack previous      # move to previous ancestor commit

git stack next --branch    # jump to next branch tip
git stack previous --branch  # jump to previous branch tip

git stack next 3        # jump 3 commits forward
```

Stash before switching:

```bash
git stack next --stash
```

## Amending Commits

Amend HEAD (descendants are automatically rebased):

```bash
git stack amend
git stack amend --all          # stage all changed files
git stack amend --interactive  # interactive add
git stack amend --message "new message"
```

Amend a specific commit:

```bash
git stack amend <rev>
```

Reword a commit message (descendants rebased automatically):

```bash
git stack reword                    # reword HEAD
git stack reword -m "new message"   # non-interactive
git stack reword <rev>              # reword specific commit
```

## Running Commands Across the Stack

Run a command at each commit in the stack (like `git bisect run`):

```bash
git stack run -- cargo test
git stack run --no-fail-fast -- make lint
git stack run --switch -- npm test   # switch to first failed commit
```

## Configuration

Protect a branch pattern:

```bash
git stack --protect "main"
git stack --protect "release/*"
```

Dump current config:

```bash
git stack --dump-config -
```

Key config fields (in `.git/config` or `~/.gitconfig`):

```ini
[stack]
    protected-branch = main
    push-remote = origin
    pull-remote = origin
    auto-fixup = squash       # ignore | move | squash
    auto-repair = true
    show-format = graph       # silent | list | graph | debug
    show-stacked = true
```

## Common Workflows

**After merging a PR — sync and rebase the rest of the stack:**

```bash
git stack sync
```

**Start work on top of an in-progress branch:**

```bash
git checkout feature-a
git checkout -b feature-b   # stack feature-b on top of feature-a
# ... make commits ...
git stack              # visualize the stack
git stack --rebase     # rebase if feature-a changed
```

**Squash fixups before pushing:**

```bash
git stack --rebase --fixup squash
git stack --push
```

**Navigate to a specific point in the stack to amend:**

```bash
git stack previous --branch   # go to parent branch
git stack amend               # amend that branch's tip
git stack next --branch       # return to child branch (auto-rebased)
```
