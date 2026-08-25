---
name: tasks
description: Conventions for task files in tasks/, covering numbering, frontmatter, subtasks, ranking, and closing. Load before creating, editing, or closing a task.
user-invocable: true
---

# Tasks

One flat directory, `tasks/` at the repo root, one file per task.
`tasks/lessons.md` is in the same directory and is not a task.

`infuse` may symlink `tasks/` into a shared store, in which case it is untracked in the repo.
Edit through the symlink as normal, and never `git add` it.
An untracked `tasks/` in `git status` is expected, not something to fix.

Older files predate this convention.
They are in `done/` and `archive/`, carry no `status` field, and put the close note above the frontmatter.
Leave them as they are unless asked.

## Naming

`PREFIX-NN-kebab-slug.md`, as in `DOTFILES-19-own-tools-to-nix.md`.

- `PREFIX` is the project, uppercase, derived from the repo name
- `NN` is the next unused number for that project
- the slug is a short description, not the whole title

## Numbers Are Permanent

A task still at `status: todo` can be renumbered, so numbering and reading order stay in step while a plan is drawn up.

The move to `in-progress`, or a commit naming the task, fixes the number for good.
After that the number is identity.
Commits reference it, other tasks link to it, and a later conversation calls it by that number.
Renumbering breaks all three at once, silently, and the damage only shows when someone follows a reference that no longer means what it said.

Renaming is fine at any point, and so is rewriting the body.
Only the number is identity, so the title and the slug can drift without cost.

A number is never reused.
A task that turns out to be unnecessary reaches `done:rejected`, and its number stays spent.
Work arriving late for something underway takes the next free number, even when it belongs earlier in the reading order.

## Frontmatter

```yaml
---
project: dotfiles
assignee: oliver
created: 2026-08-24
status: todo
rank: 12000
requires:
  - DOTFILES-14
parent: DOTFILES-19
---
```

- `project`: lowercase project name
- `assignee`: who owns it
- `created`: absolute date, `YYYY-MM-DD`, never relative
- `status`: `todo`, `in-progress`, `done:completed`, `done:rejected`
- `rank`: the order to work in
- `requires`: optional, hard prerequisites by number
- `parent`: optional, the task this one is a step of

Frontmatter starts at line 1 so it stays machine-readable.
Nothing goes above it.

### Status

- `todo` has not been started, and the number can still move
- `in-progress` means work has begun, which fixes the number for good
- `done:completed` means the Definition of Done actually passed
- `done:rejected` means the work turned out to be unnecessary, and the number stays spent

Test for the `done:` prefix to mean finished either way.

### Rank

`rank` is the order to work in, spaced 1000 apart.
Moving one is the midpoint between its neighbours, so the gaps stay wide enough to keep doing that.
The number orders the file on disk and `rank` orders the work, so finishing them out of numerical order needs no renumbering.

Rank is global across the project.
A subtask ranks among every other task, not only among its siblings.

### Requires

`requires` lists the tasks that must be finished first, by number.
A requirement is a hard one.
Something merely worth reading first is a sentence in the body.
Numbers never change, so a `requires` entry cannot rot.

Blocked is not a field.
A task is blocked when something it requires is not at a `done:` status.
Derive blocked from the facts rather than storing it alongside them.

## Subtasks

A task too big for one commit becomes a parent, and its steps are ordinary tasks carrying `parent: PROJECT-NN`.

- there is no `NN.M` numbering, so every task keeps a flat number and reparenting is a frontmatter edit
- each step is green by itself, with its own Definition of Done
- a parent holds the ordering and the reasoning, and little else
- closing a parent does not close its steps, and open steps do not block closing it

When every child of a parent has reached a `done:` status, offer to close the parent.
Do not close it unprompted.

## Writing the File

The H1 repeats the ticket ID, separated from the title by a colon:

```markdown
# DOTFILES-20: Certificate and domain expiry alerts
```

The separator is always a colon.

State the goal in the first paragraph, before any plan.

A task needs a completion condition.
A standing index of everything not yet done regenerates itself and is not a task, so enumerate a finite set and finish it.

### Definition of Ready

Every task has a Definition of Ready listing what must be true before work starts.
It is the gate on moving from `todo` to `in-progress`.

```markdown
## Definition of Ready

- every entry in `requires` has reached a `done:` status
- the 1Password item holding the API token exists and is readable
- it is decided whether the Swift tools build from source or ship prebuilt
```

Write the preconditions that would change the approach if they turned out false.
A dependency already captured in `requires` does not need repeating here unless something about it needs checking.

If a Definition of Ready cannot be satisfied, the task stays `todo`.
That is what blocked looks like, and it is why blocked is derived rather than stored.

### Definition of Done

Every task ends with a Definition of Done listing falsifiable checks.
Each is a command and the result it should produce, so someone who did not write the task can run it and get an unambiguous answer.

```markdown
## Definition of Done

- `command -v mission` prints a path under the per-user profile
- `readlink -f ~/.config/mission/config.toml` resolves into `/nix/store`
- `mission tasks --json` matches the output captured before the change
- `sketchybar --trigger mission_task` exits 0
```

Write it before starting the work, not after.
Deciding what proof would satisfy you is the point, and reverse-engineering it later defeats it.

A Definition of Done proves the plan that was written.
It does not find the plan that was missed, so it is not a substitute for asking what else depends on the thing being changed.

## Closing a Task

Set `status` to `done:completed` or `done:rejected`, then put a close note directly below the frontmatter, above the title:

```markdown
---
project: dotfiles
status: done:rejected
---

> **Closed 2026-08-24, unbuilt.** One paragraph on what happened, and what a reader
> restarting this needs to know that the plan below no longer tells them.

# DOTFILES-20: Certificate and domain expiry alerts
```

A rejected task is worth more than a deleted one when the research behind it was expensive.
Say what the plan got wrong so nobody rediscovers it.

### Editing a Closed Task

A closed task is the record of what was built, or of why it was dropped.
Correcting one that turned out to be wrong keeps the record accurate.
Rewriting it to match what you wish had happened destroys it.
The line between those is a judgement call, so ask before editing a closed task.

## Out of Scope

A task says what to do and how to know it worked.
No links to these conventions, and no paths into them.
Finding the reasoning is the reader's problem to solve once.
A reference goes stale in sixteen files at a time.

Reference other tasks by number, not by path.
Config and code must never link back to task files, because tasks move and rot.

## Linting

Lint every task file before considering it done:

```sh
rumdl check tasks/PREFIX-NN-slug.md
vale tasks/PREFIX-NN-slug.md
```

`rumdl` covers markdown structure, `vale` covers prose.
Both read global config from `~/.config/`, so no per-repo setup is needed.
`rumdl fmt` fixes most of what it reports.
Fix what they find rather than suppressing it.
