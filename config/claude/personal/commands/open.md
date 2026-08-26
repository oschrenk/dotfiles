---
description: Open a file in neovim running in the tmux pane to the left
argument-hint: <filepath>
---

# Open in Neovim

Open the specified file in the neovim instance running in the tmux pane to the left of Claude Code.

## Arguments

`$ARGUMENTS` contains the file path to open.

## Instructions

1. Determine the file path to open:
   - If `$ARGUMENTS` is provided, use that as the file path.
   - If `$ARGUMENTS` is empty, use the most recent file you read or edited in this conversation. If there is none, ask the user which file to open.

2. Resolve the file path to an absolute path. If the path is relative, resolve it against the current working directory.

3. Run the following bash command to open the file in neovim in the left tmux pane:

```bash
tmux send-keys -t '{left}' Escape ':e <absolute_filepath>' Enter
```

4. Confirm to the user that you sent the file to neovim.

## Notes

- The `Escape` key ensures neovim is in normal mode before sending the `:e` command.
- This assumes neovim is running in the tmux pane directly to the left of Claude Code's pane.
- If tmux is not available or the command fails, inform the user.
