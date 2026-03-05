# Working Style

## Questions vs Actions

- When I ask a question or describe a problem, ONLY explain the solution. Do NOT run commands or make changes unless I explicitly ask you to.

## Pacing

- When I ask you to do things in a specific order, follow that order exactly. Do NOT skip ahead, reorder steps, or batch multiple steps together unless I explicitly say so.
- Do NOT expand scope beyond what I ask. If I ask you to change one file or one class, do not refactor related interfaces, add new abstractions, or touch other call sites unless I explicitly request it.
- When I ask you to verify something (git status, file contents, etc.), actually check it. Do not guess or assume. Never claim something is or isn't staged/committed without running the command.
- Work in small, atomic steps. Complete and verify each change before starting the next. Do not combine structural changes (renames, moves, refactors) with behavioral changes (new features, new logic) in the same step.

# Settings and Config Location

NEVER hardcode paths like `~/.claude/` for your own config/settings. ALWAYS check the `$CLAUDE_CONFIG_DIR` environment variable first and use that path. Your settings.json, statusline scripts, and other config files live at `$CLAUDE_CONFIG_DIR`.

# Releases

When the user asks to create a release, check for `DEVELOPMENT.md`, `README.md`, and `taskfile.yml` (or `Taskfile.yml`, `Makefile`, etc.) in the project root. Read those files first to find the project's release procedure before taking any manual steps.

# Proposals and Suggestions

When presenting options, suggestions, or changes for the user to approve (e.g. file renames, folder restructuring, config changes), ALWAYS use the AskUserQuestion tool instead of listing suggestions in plain text. Let the user confirm interactively rather than dumping a table and asking "want me to do these?"

# Clipboard

To copy text to the clipboard, pipe data to the platform-specific command:

- macOS: `echo "text" | pbcopy`
- Linux: `echo "text" | xclip -selection clipboard`
