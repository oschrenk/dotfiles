---
name: tasks
description: Conventions for task files in tasks/, covering numbering, frontmatter, subtasks, ranking, and closing. Load before creating, editing, or closing a task.
user-invocable: true
---

# Tasks

One flat directory, `tasks/` at the repo root, one file per task.

`infuse` may symlink `tasks/` into a shared store, in which case it is untracked in the repo.
Edit through the symlink as normal, and never `git add` it.
An untracked `tasks/` in `git status` is expected, not something to fix.

Older files predate this convention.
They are in `done/` and `archive/`, carry no `state` field, and put the close note above the frontmatter.
Leave them as they are unless asked.

## Naming

`PREFIX-NN-kebab-slug.md`, as in `DOTFILES-19-own-tools-to-nix.md`.

- `PREFIX` is the project, uppercase, derived from the repo name
- `NN` is the next unused number for that project
- the slug is a short description, not the whole title

## Numbers Are Permanent

You can renumber a task still at `state: todo`, so numbering and reading order stay in step while a plan is drawn up.

The move to `in-progress`, or a commit naming the task, fixes the number for good.
After that the number is identity.
Commits reference it, other tasks link to it, and a later conversation calls it by that number.
Renumbering breaks all three at once, silently, and the damage only shows when someone follows a reference that no longer means what it said.

Renaming is fine at any point, and so is rewriting the body.
Only the number is identity, so the title and the slug can drift without cost.

Never reuse a number.
A task that turns out to be unnecessary reaches `done:rejected`, and its number stays spent.
Work arriving late for something underway takes the next free number, even when it belongs earlier in the reading order.

## Frontmatter

```yaml
---
project: dotfiles
assignee: oliver
created: 2026-08-24
state: todo
rank: 12000
requires:
  - DOTFILES-14
parent: DOTFILES-19
---
```

- `project`: lowercase project name
- `assignee`: who owns it
- `created`: absolute date, `YYYY-MM-DD`, never relative
- `state`: `todo`, `in-progress`, `done:completed`, `done:rejected`
- `rank`: the order to work in
- `requires`: optional, hard prerequisites by number
- `parent`: optional, the task this one is a step of
- `closed`: set when the task closes, absolute date, `YYYY-MM-DD`
- `outcome`: set when the task closes, the close note

Frontmatter starts at line 1 so it stays machine-readable.
Nothing goes above it.

### State

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
A task is blocked when something it requires is not at a `done:` state.
Derive blocked from the facts rather than storing it alongside them.

## Subtasks

A task too big for one commit becomes a parent, and its steps are ordinary tasks carrying `parent: PROJECT-NN`.

- there is no `NN.M` numbering, so every task keeps a flat number and reparenting is a frontmatter edit
- each step is green by itself, with its own Definition of Done
- a parent holds the ordering and the reasoning, and little else
- closing a parent does not close its steps, and open steps do not block closing it

When every child of a parent has reached a `done:` state, offer to close the parent.
Do not close it unprompted.

## Writing the File

The H1 repeats the ticket ID, separated from the title by a colon:

```markdown
# DOTFILES-20: Certificate and Domain Expiry Alerts
```

The separator is always a colon, and the title takes title case, which is what `rumdl` enforces.

### Backticks

Tools, binaries, formulae, commands, paths, filenames, config keys and task-runner targets go in backticks, in headings as much as in prose.

In a heading this is not decoration.
`rumdl`'s MD063 rule rewrites headings to title case, so a bare `tmignore-rs` becomes `Tmignore-Rs` and a bare `spicetify` becomes `Spicetify`.
Those are names that do not exist, and the rewrite is silent.
A code span exempts the word, so the backticks fix the lint and the correctness in one move.

`rumdl fmt` rewrites headings and rewraps paragraphs, which has consequences for editing a file after formatting it:

- a script that edits a task file by matching a heading or a sentence verbatim will
  match nothing after a format run, so assert on the match count rather than trusting
  `replace` to have done anything
- write the file, then format it, then read back what you have before editing it again

State the goal in the first paragraph, before any plan.

A task needs a completion condition.
A standing index of everything not yet done regenerates itself and is not a task, so enumerate a finite set and finish it.

### Definition of Ready

Every task has a Definition of Ready listing what must be true before work starts.
It is the gate on moving from `todo` to `in-progress`.

The test is whether someone who has never seen the problem could pick the file up and work it without asking a question first.
An agent will not ask.
It will guess, and the guess will look confident.

A task is ready when you have done all of these.

**State the problem in observable terms.**
What is broken, missing, or too expensive right now.
Write the symptom rather than the remedy, because naming the remedy first hides whether the problem was understood.

**Name the end state.**
The end state, and how the world differs once the task closes.
One or two sentences, before any plan.

**Write a falsifiable Definition of Done.**
Every check is a command and the result it should produce.
A task without one is not ready, however clear its plan reads.

**Write the scope boundary down.**
What this task will not touch, especially the adjacent things that look like they belong.
Unstated scope is the gap an agent fills on its own.

**Enumerate the consumers.**
Everything that calls, imports, or reads the thing being changed, found by searching rather than by memory.
A change that looks local is only local once you run that search.

**Record the baseline.**
For a change to something already working, record the current behaviour first so you can compare the result against it.
An output saved before the work is worth more than any assertion made after it.

**Resolve or mark the open decisions.**
Any fork that would change the approach is either decided in the file, or named as one to ask about before proceeding.
A task that hides a decision gets the agent's preference instead of yours.

**Name the undo.**
How to get back if the change is wrong, and whether anything about it cannot be undone.

If you cannot satisfy a Definition of Ready, the task stays `todo`.
That is what blocked looks like, and it is why blocked is derived rather than stored.

```markdown
## Definition of Ready

- **Problem** sketchybar shows an empty Sessions item, and `sessionizer` cannot find
  `tmux` when launchd starts it
- **Goal** sessionizer resolves tmux by absolute path, so the launchd PATH override
  can be removed
- **Scope** packaging and config only, no changes to the fuzzy finder or layouts
- **Consumers** `grep -rn "homebrew/bin/sessionizer\|made/sessionizer" home/ nix/`
  returns 4 files, all listed below
- **Baseline** `sessionizer sessions --json > /tmp/before.json`
- **Open** whether to add a `base.tmux_path` key upstream, or keep the PATH override
- **Undo** revert the commit and `chezmoi apply` the two lua files
```

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

A task closes as `done:completed` when you have done all of these.

**Run the checks, and make sure they pass.**
Run means executed, with the output looked at.
A check skipped because its outcome seemed obvious is a check that did not run, and reporting it as passed is a false record.

**Falsify the checks where you can.**
A check that passes whether or not the work happened proves nothing about the work.
Undo the change, run the check again, and confirm that it fails.
Restore the change and confirm that it passes.
Do this for the checks that carry the result, not for every line.
Where undoing is impractical or destructive, write in the task which checks went unfalsified and why.

**Match the specs to the system.**
Any document describing how the thing works now describes how it works.
This includes the task file itself, whose plan often drifts from what was built.
A stale spec does more damage than a missing one, because it gets trusted.

A Definition of Done proves the plan that was written.
It does not find the plan that was missed, so it is not a substitute for asking what else depends on the thing being changed.

## Closing a Task

Set `state` to `done:completed` or `done:rejected`, then add `closed` and `outcome` to the frontmatter.
The body is left exactly as it was.

```markdown
---
project: dotfiles
state: done:rejected
rank: 12000
closed: 2026-08-24
outcome: >
  One paragraph on what happened, and what a reader restarting this
  needs to know that the plan below no longer tells them.
---

# DOTFILES-20: Certificate and Domain Expiry Alerts
```

The close note goes in the frontmatter rather than above the H1 because MD041 requires the first line of a document to be a level 1 heading, and a note above the title breaks that on every closed file at once.
Weakening the rule to accept it would stop it catching stray prose everywhere else, so the note moves instead.

`outcome` is a folded block scalar, `>`, so the source can be written a sentence per line and still parse as one paragraph.
Indent every line of it by two spaces.
Indentation is the only thing that ends the scalar, so a line that loses it ends the note early and the parser reads the rest of the file as frontmatter.
Everything inside is literal, so a note may contain colons, backticks and `#` without escaping.
A blank line inside the scalar is a paragraph break, which is where a later amendment goes.

A rejected task is worth more than a deleted one when the research behind it was expensive.
Say what the plan got wrong so nobody rediscovers it.

### Editing a Closed Task

A closed task is the record of what was built, or of why it was dropped.
Correcting one that turned out to be wrong keeps the record accurate.
Rewriting it to match what you wish had happened destroys it.
The line between those is a judgement call, so ask before editing a closed task.

## Querying Frontmatter

`yq` reads and writes the frontmatter block directly, which is what makes `state`, `rank` and `requires` worth carrying as fields rather than as prose.

One file:

```sh
yq --front-matter=extract '.rank' tasks/PREFIX-NN-slug.md
```

Many files, one at a time.
Passing several paths to `--front-matter=extract` prints the first results and then fails on the last with `did not find expected <document start>`, so loop rather than glob:

```sh
for f in tasks/PREFIX-*.md; do
  printf '%-52s %-14s %s\n' "$(basename "$f")" \
    "$(yq --front-matter=extract '.state // "-"' "$f")" \
    "$(yq --front-matter=extract '.rank' "$f")"
done
```

That one loop answers what to pick up next.
It also shows which files are missing a `state`, and whether two tasks share a `rank`.

Writing uses `--front-matter=process`, which re-emits the body byte for byte:

```sh
yq --front-matter=process -i '.state = "in-progress"' tasks/PREFIX-NN-slug.md
```

A write that adds a field appends it below the existing ones, past the order above.
`pick` puts it back, and drops the names it does not find rather than writing nulls:

```sh
yq --front-matter=process -i \
  '.state = "todo" | pick(["project","assignee","created","state","rank","requires","parent","closed","outcome"])' \
  tasks/PREFIX-NN-slug.md
```

### Not on a File That Has an `outcome`

A write reflows every block scalar in the frontmatter.
`outcome` is written a sentence per line and comes back as one line per paragraph, with a blank line added before the closing `---`.
The YAML parses to the same string and the file still lints, so nothing breaks.
The diff is the whole note, and the sentence-per-line source is gone.

Use `yq` for the scalar fields, and edit a file with an `outcome` in it by hand.
Closing sets `state`, `closed` and `outcome` in one go, so closing is a by-hand edit.

`mdq` parses the block too, exposing it under `--output json` as a `front_matter` node with a raw `body` string.
It has no selector for it, so it cannot filter on these fields.

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
