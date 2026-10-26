---
name: lific
description: Conventions for issues and plans in lific, the issue tracker behind the mcp__lific__* tools, covering projects, keys, issue content, status, priority, blockers and closing. Load before creating, editing, or closing an issue.
user-invocable: true
---

# Lific

Lific holds every ticket and work item.
The server instructions cover the tool mechanics.
This skill covers what makes an issue good enough to work.

## Projects

Each project is one repository, and its description names that repository.
Find the project with `list_resources(resource_type='project')` and match the repository.
Do not guess a project key from the repository name.

## Keys

An issue key is the project key, a dash and a number, as in `LAB-42`.
Lific assigns the number on create, so never predict it.
Name an issue by its key in commits, in other issues and in conversation.

Issues migrated from the old `tasks/` files keep their old key in the first line of the description, as `Original key: <OLD-KEY>`.
The old prefix differs from the lific project key.
To resolve an old key from a commit or a doc, search for it with `search(query='<OLD-KEY>', mode='literal')`.
Do not derive the new key from the number alone, because numbering can differ between the two.

## Before Creating

Search the project for existing coverage first.
Extend an existing issue rather than filing a second one.

File the issue in a module when the project has modules.
Do not create a module unless Oliver asks.

## Writing the Description

State the goal in the first paragraph, before any plan.
Put tools, binaries, commands, paths, filenames, config keys and task-runner targets in backticks, in the title as much as in the body.

An issue needs a completion condition.
A standing index of everything not yet done is not an issue, so enumerate a finite set and finish it.

### Definition of Ready

An issue is ready when someone who has never seen the problem can work it without a question first.
An agent will not ask.
It will guess, and the guess will look confident.

```markdown
## Definition of Ready

- **Problem** the symptom in observable terms, not the remedy
- **Goal** the end state in one or two sentences
- **Scope** what this issue will not touch, especially the adjacent things that seem to belong
- **Consumers** everything that calls, imports or reads the thing being changed, found by a search that is quoted here
- **Baseline** the current behaviour, recorded before the work
- **Open** each fork that would change the approach, decided here or marked to ask about first
- **Undo** how to get back, and anything that cannot be undone
```

An issue is ready only when it has both a Definition of Ready and a Definition of Done.
The Definition of Ready must also hold the result of every research and verification step it needs.
Record each fact you checked, each command you ran with its output, and each answer to an open question.
A step that says "find out" or "check" without a result keeps the issue in `backlog`.

### Plan

A checklist of bounded steps, in order.

### Definition of Done

Every check is a command and the result it must produce.
Write it before the work starts, not after.

```markdown
## Definition of Done

- `command -v mission` prints a path under the per-user profile
- `mission tasks --json` matches the output captured before the change
```

## Status

- `backlog`: the Definition of Ready does not hold yet
- `todo`: ready, and nobody has started
- `active`: work has begun
- `done`: the Definition of Done passed
- `cancelled`: the work turned out to be unnecessary

Create an issue as `todo` only when its Definition of Ready holds, and as `backlog` otherwise.

## Priority

`urgent`, `high`, `medium`, `low` or `none`.
Use the priority that Oliver asked for, and `none` when the request names no priority.
"Highest priority" means `urgent`.

## Blockers and Waits

A hard prerequisite is `link_issues(source=<prerequisite>, target=<issue>, relation_type='blocks')`.
Something merely worth reading first is a sentence in the description, or `relates_to`.
Lific derives blocked from open blockers, so do not write it into the description.

A step that only a person can do gets `assignees=['human']`.
A rebuild that needs Full Disk Access is one example, and a web action in an account is another.

## Large Work

Work too big for one commit becomes a plan with `create_plan`.
Each step that is its own change mirrors an issue, and each such issue has its own Definition of Done.
Give the plan an `anchor_issue` when one issue holds the reasoning.

## Editing

Use `edit_issue` for small changes, and `update_issue` with `expected_seq` for a full rewrite.
A `done` or `cancelled` issue is the record of what happened.
Ask before editing one.

## Closing

Close as `done` only after you ran every Definition of Done check and looked at the output.
Pass the commands and their results as `evidence` on the same `update_issue` call.
Where you can, falsify the checks that carry the result.
Undo the change and confirm that the check fails, then restore the change.
Name each check that you cannot falsify, and why.

Close as `cancelled` with a comment that says what the plan got wrong, so nobody rediscovers it.
