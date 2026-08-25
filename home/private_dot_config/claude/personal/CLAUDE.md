# Workflow Orchestration

## 1. Plan Mode Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

## 2. Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

## 3. Self-Improvement Loop
- After ANY correction from the user: update tasks/lessons.md with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project

## 4. Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

## 5. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes -- don't over-engineer
- Challenge your own work before presenting it

# Task Management

## Workflow

1. Plan First: write the plan into the task file as checkable items
2. Verify Plan: check in before you start building
3. Track Progress: mark items complete as you go
4. Explain Changes: high-level summary at each step
5. Document Results: add a review section to the task file
6. Capture Lessons: update `tasks/lessons.md` after corrections

## Task Files

Tasks are one file per task in `tasks/` at the repo root, as `PREFIX-NN-kebab-slug.md`.
Every task has frontmatter starting at line 1, a Definition of Ready, and a Definition of Done.

Load the `tasks` skill before creating, editing, or closing a task file.
The skill holds the rules that are expensive to get wrong: numbering is permanent once a task leaves `todo`, numbers are never reused, `rank` is spaced 1000 apart, and subtasks are ordinary tasks with a `parent` key.
Do not write a task file from memory of this paragraph.

`tasks/` is often symlinked into a shared store and shows as untracked.
That is expected.
Never `git add` it.


# Core Principles
- Simplicity First: Make every change as simple as possible. Impact minimal code.
- No Laziness: Find root causes. No temporary fixes. Senior developer standards.
- Minimal Impact: Only touch what's necessary. No side effects with new bugs.

# Working Style

- When I ask you to do things in a specific order, follow that order exactly. Do NOT skip ahead, reorder steps, or batch multiple steps together unless I explicitly say so.
- Do NOT expand scope beyond what I ask. If I ask you to change one file or one class, do not refactor related interfaces, add new abstractions, or touch other call sites unless I explicitly request it.
- When I ask you to verify something (git status, file contents, etc.), actually check it. Do not guess or assume. Never claim something is or isn't staged/committed without running the command.

# Proposals and Suggestions

When presenting options, suggestions, or changes for the user to approve (e.g. file renames, folder restructuring, config changes), ALWAYS use the AskUserQuestion tool instead of listing suggestions in plain text. Let the user confirm interactively rather than dumping a table and asking "want me to do these?"

# Markdown Formatting

- Do NOT put a horizontal rule (`---`) before headings. Headings already separate sections; the rule adds visual noise and clutters the diff. This applies to files you write and to your replies.
- Use `---` only when it genuinely marks a break between unrelated parts of a document, not as decoration between every section.

# Web

- When fetching/reading a web page (as opposed to searching), always prefer lightpanda via the `fetch-websites` skill instead of the built-in WebFetch. It renders JavaScript and handles SPAs.

# Shell

- My interactive shell is **fish**, not bash/zsh. Commands you hand me to run myself (e.g. `! ...` in the prompt) must be fish-compatible.
- fish has **no heredocs** (`<<'EOF'`) and no `$(...)`-nested heredocs. To pass multi-line content (PR bodies, commit messages, file content), write it to a file and reference it with a flag like `--body-file` / `--file`, or use `printf`.
- Other fish differences to watch for: `set VAR value` (not `VAR=value`), `set -x` for exports, `$status` (not `$?`), `; and`/`; or` (not `&&`/`||` in some contexts — though `&&`/`||` do work in modern fish), and no `export`/`source ~/.bashrc` idioms.
- Commands I run via the Bash tool execute in a bash-like sandbox, so bash syntax is fine there — the fish caveats only matter for commands you give *me* to paste and run.

# Clipboard

To copy text to the clipboard, pipe data to the platform-specific command:

- macOS: `echo "text" | pbcopy`

