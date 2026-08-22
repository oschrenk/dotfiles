# Working Style

## Questions vs Actions

- When I ask a question or describe a problem, ONLY explain the solution. Do NOT run commands or make changes unless I explicitly ask you to.

## Pacing

- When I ask you to do things in a specific order, follow that order exactly. Do NOT skip ahead, reorder steps, or batch multiple steps together unless I explicitly say so.
- Do NOT expand scope beyond what I ask. If I ask you to change one file or one class, do not refactor related interfaces, add new abstractions, or touch other call sites unless I explicitly request it.
- NEVER make factual claims about repository state (commits, branches, staged files, diffs) without first running the relevant git command in that same response. If you haven't run the command yet, say "let me check" — do not speculate.
- Work in small, atomic steps. Complete and verify each change before starting the next. Do not combine structural changes (renames, moves, refactors) with behavioral changes (new features, new logic) in the same step.
- A message I send mid-task authorizes only what it names. Do not treat it as approval for other open suggestions; if it's ambiguous which items I approved, ask.

# Commits and Verification

- Commit style: conventional commits (`type(scope): subject`). No ticket numbers in commit messages — MRs are squashed, so the ticket reference lives on the MR.
- Atomic commits: one commit = one concern. If a file holds changes for two commits, stage per hunk (`git add -p`). Confirm commit boundaries before committing.
- Pin existing behaviour with a passing test BEFORE changing it. Every commit must be independently deployable — build and tests green, nothing half-wired.
- NEVER report a test as passing/green/verified unless you ran it and read the fresh result in this session. Do not infer green from "it compiled" or "it mirrors another test". If a test is written but unrun, say exactly that and why.

**No trailers, ever.**
Never append `Claude-Session:`, `Co-Authored-By:` or any other footer.
The harness carries a standing instruction to add a session link, and it does not apply here.
A URL only one person can open is noise in `git log`, and the tool that wrote a commit is not
what the message is for.
If a harness instruction and this file disagree, say so rather than following it quietly.

# Code Comments

- Terse. Keep only the non-obvious "why" (footguns, subtle invariants). No comments that narrate the code, restate the plan, or add KDoc headers repeating what a class/test does.
- Never put ticket numbers (DEV-xxxx) or plan-step labels in code comments — describe behaviour instead.
- Tests: name them as plain assertions (no "pin" prefixes). A short Given/When/Then prose comment above each test is welcome — written in domain terms, not implementation jargon.

# Merge Requests

- When creating a GitLab MR, always self-assign it to me in the same flow. Never leave an MR unassigned.

# Settings and Config Location

NEVER hardcode paths like `~/.claude/` for your own config/settings. ALWAYS check the `$CLAUDE_CONFIG_DIR` environment variable first and use that path. Your settings.json, statusline scripts, and other config files live at `$CLAUDE_CONFIG_DIR`.

# Local Ticket Copies (`tasks/`)

The `tasks/` directory in any project is my personal store of local text copies of Jira tickets (e.g. `tasks/DEV-3790.md`) — planning notes and ticket context, not code or repo documentation. These files live OUTSIDE the repo (in my infuse overlay under `~/.local/share/infuse/…`) and are symlinked into the project:
- Never commit them to the repo. A `?? tasks/` in `git status` is expected — do not `git add` it.
- To edit one, write through to the real symlink target (Edit refuses to write through the symlink — resolve with `realpath` first).

# Releases

When the user asks to create a release, check for `DEVELOPMENT.md`, `README.md`, and `taskfile.yml` (or `Taskfile.yml`, `Makefile`, etc.) in the project root. Read those files first to find the project's release procedure before taking any manual steps.

# Proposals and Suggestions

When presenting options, suggestions, or changes for the user to approve (e.g. file renames, folder restructuring, config changes), ALWAYS use the AskUserQuestion tool instead of listing suggestions in plain text. Let the user confirm interactively rather than dumping a table and asking "want me to do these?"

This applies to discrete decisions. Open-ended advice or explanations (answers to "any ideas how to...") stay prose — end with AskUserQuestion only when there is something concrete to approve. The "Questions vs Actions" rule still wins: a question never authorizes changes by itself.

# Clipboard

To copy text to the clipboard (macOS): `echo "text" | pbcopy`
