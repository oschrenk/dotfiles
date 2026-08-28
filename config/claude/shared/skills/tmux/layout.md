# Layout Management

Splitting, resizing, and rearranging tmux panes.

## Split Window

```bash
tmux split-window [-h|-v] [-t <target>] [-l <size>|-p <percentage>] [command]
```

| Flag | Effect |
|------|--------|
| `-h` | Split horizontally (new pane to the right) |
| `-v` | Split vertically (new pane below) — default |
| `-t <target>` | Split relative to this pane |
| `-l 40` | New pane is 40 cells |
| `-p 30` | New pane is 30% of available space |
| `-b` | Place new pane before target (left/above) |
| `-d` | Don't switch focus to the new pane |

Append a command to run it in the new pane, e.g.:

```bash
tmux split-window -h 'htop'
```

## Resize Pane

```bash
tmux resize-pane [-D|-U|-L|-R] <n> [-t <target>]
```

| Flag | Direction |
|------|-----------|
| `-D <n>` | Down by n cells |
| `-U <n>` | Up by n cells |
| `-L <n>` | Left by n cells |
| `-R <n>` | Right by n cells |

**Zoom toggle** — maximize/restore a pane:

```bash
tmux resize-pane -Z [-t <target>]
```

**Set exact size:**

```bash
tmux resize-pane -x <width> -y <height> [-t <target>]
```

## Preset Layouts

Apply a built-in layout to the current window:

```bash
tmux select-layout <layout-name>
```

| Layout | Description |
|--------|-------------|
| `even-horizontal` | All panes side by side, equal width |
| `even-vertical` | All panes stacked, equal height |
| `main-horizontal` | One large pane on top, others below in a row |
| `main-vertical` | One large pane on left, others stacked on right |
| `tiled` | Panes arranged in a grid |

## Rotate / Rearrange Panes

Rotate pane positions within the current window:

```bash
tmux swap-pane -U    # Move active pane up in order
tmux swap-pane -D    # Move active pane down in order
```

To cycle all panes forward or backward:

```bash
tmux rotate-window [-D|-U]
```

`-U` rotates up (counter-clockwise), `-D` rotates down (clockwise, default).
