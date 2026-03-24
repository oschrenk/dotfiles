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
1. Plan First: Write plan to tasks/todo.md with checkable items
2. Verify Plan: Check in before starting implementation
3. Track Progress: Mark items complete as you go
4. Explain Changes: High-level summary at each step
5. Document Results: Add review section to tasks/todo.md
6. Capture Lessons: Update tasks/lessons.md after corrections

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

# Clipboard

To copy text to the clipboard, pipe data to the platform-specific command:

- macOS: `echo "text" | pbcopy`

