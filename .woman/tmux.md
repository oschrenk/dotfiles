* `Ctrl-b` is default prefix
* `Ctrl-b ?` List of keyboard shortcuts

## Sessions
- Creating a session `tmux new-session -s work`
- Attach to a session `tmux attach -t work`
- `Ctrl-b d` Detach from a session
- `Ctrl-b (` Previous session
- `Ctrl-b )` Next session
- `Ctrl-b L` Last session
- `Ctrl-b s` Choose session from list
- `Ctrl-b $` Rename session

## Windows
- `Ctrl-b l` Move to the selected window
- `Ctrl-b n/p` Move to the next/previous window
- `Ctrl-b &` Kill the current window
- `Ctrl-b 1 …`  Switch to window 1, ..., 9, 0
- `Ctrl-b w` Choose window from a list
- `Ctrl-b ,` Rename the current window
- `Ctrl-b &` Kill the current window

## Panes
- `C-a "` Split vertically (top/bottom)
- `C-a %` Split horizontally (left/right)
- `C-a (left|right|up|down)` Go to next pane in that direction
- `Ctrl-b o` Cycle through panes
- `Ctrl-b ;` Go to the previously used pane
- `Ctrl-b }/{` Move current pane to next/previos position
- `Ctrl-b Ctrl-o` Rotate window ‘up’
- `Ctrl-b Alt-o` Rotate window ‘down’
- `Ctrl-b !` Break current pane into new window
- `Ctrl-b x` Kill current pane
- `Ctrl-b q` Display pane numbers for a while

- `Ctrl-b Alt-(left|right|up|down)` Resize by 5 rows/columns
- `Ctrl-b Ctrl-(left|right|up|down)` Resize by 1 row/column

- `Ctrl-b M-1` Switch to even-horizontal layout
- `Ctrl-b M-2` Switch to even-vertical layout
- `Ctrl-b M-3` Switch to main-horizontal layout
- `Ctrl-b M-4` Switch to main-vertical layout
- `Ctrl-b M-5` Switch to tiled layout
- `Ctrl-b space` Switch to the next layout

