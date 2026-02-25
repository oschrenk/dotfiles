---
name: tmux-operations
description: "Use when user asks about tmux panes, windows, or layouts — reading pane content, moving processes between panes/windows, splitting, resizing, or rearranging."
user-invocable: true
---

# tmux Operations

## Orientation

Always start by getting the current tmux context:

```bash
tmux display-message -p '#S:#I.#P'
```

Then list all panes in the session:

```bash
tmux list-panes -s -F '#{window_index}.#{pane_index} #{pane_current_command} #{pane_width}x#{pane_height} #{?pane_active,*,}'
```

This tells you the session, active window/pane, what's running in each pane, and their sizes.

**List all sessions:**

```bash
tmux list-sessions -F '#{session_name} #{session_windows} windows #{?session_attached,(attached),}'
```

**List windows in a session:**

```bash
tmux list-windows -t <session> -F '#{window_index} #{window_name} #{window_panes} panes #{?window_active,*,}'
```

## Read Pane Content

Capture visible content plus 500 lines of scrollback from a target pane:

```bash
tmux capture-pane -t <target> -p -S -500
```

**Targeting panes:**

| Target | Meaning |
|--------|---------|
| `{left}` | Pane to the left of active |
| `{right}` | Pane to the right of active |
| `{up}` | Pane above active |
| `{down}` | Pane below active |
| `0.1` | Window 0, pane 1 |
| `%5` | Pane ID 5 (absolute) |

To read less scrollback, adjust `-S` (e.g., `-S -50` for 50 lines). Omit `-S` for only the visible area.

## Quick Move / Swap

**Move pane to its own window:**

```bash
tmux break-pane -t <target>
```

Omit `-t` to break the active pane.

**Swap two panes:**

```bash
tmux swap-pane -s <src> -t <dst>
```

**Join a window as a pane in another window:**

```bash
tmux join-pane -s <src> -t <dst>
```

Add `-h` for a horizontal split or `-v` for vertical (default).

## Advanced Workflows

- For **guided move workflows** (interactive pane selection, edge cases, preserving focus) → read `move.md`
- For **layout management** (splitting, resizing, preset layouts, rearranging) → read `layout.md`
