# Move Workflows

Guided workflows for moving panes and windows in tmux.

## Interactive Pane Move

Follow these steps when the user wants to move a pane:

1. **List panes** — run orientation commands from SKILL.md to show the current layout.
2. **Ask the user** — use AskUserQuestion to confirm:
   - Which pane to move (offer panes by index and current command)
   - Where to move it (new window, existing window, or swap with another pane)
3. **Execute** the appropriate command and confirm the result.

## Break Pane (Pane → New Window)

```bash
tmux break-pane -t <target>
```

- Omit `-t` to break the currently active pane.
- The new window is created at the next available index.
- Add `-d` to keep focus on the original window instead of following the pane.

## Join Pane (Window → Pane)

```bash
tmux join-pane -s <src> -t <dst> [-h|-v] [-l <size>|-p <percentage>]
```

| Flag | Effect |
|------|--------|
| `-h` | Join horizontally (side by side) |
| `-v` | Join vertically (stacked) — default |
| `-l 40` | Set joined pane to 40 cells |
| `-p 30` | Set joined pane to 30% of available space |
| `-d` | Don't switch focus to the joined pane |
| `-b` | Place the joined pane before the target (left/above) |

## Swap Pane

```bash
tmux swap-pane -s <src> -t <dst>
```

- Swaps the positions of two panes without changing their content.
- Use `-d` to keep focus on the original pane position.

## Edge Cases

**Moving the active pane (where Claude is running):**
- After `break-pane`, Claude's pane moves to a new window. The session continues normally.
- Warn the user that their terminal context will shift.

**Preserving focus:**
- Add `-d` to any move command to keep focus on the current pane/window.
- Ask the user whether they want to follow the moved pane or stay put.
