# SplitView
`SplitView` is a [Hammerspoon](https://www.hammerspoon.org) Spoon which can automate the painful chore or putting two windows side by side in fullscreen split-view.  The typical use is to navigate to the window you'd like on the left side of the split view, invoke a key shortcut, choose another window from the popup, and watch the magic happen. You can also create special bindings to search by application and/or window name, or even invoke `SplitView` from the command line.  And as a bonus you can bind a shortcut key to toggle focus while in split view from one side to the other. 

Important points:
* `SplitView` relies on the undocumented `spaces` API, which _must_ be installed separately for it to work; see https://github.com/asmagill/hs._asm.undocumented.spaces
* This tool works by _simulating_ the split-view user interface: a long green-button click followed by a 2nd window click.  This requires hand tuned time delays to work reliably.  If it is unreliable for you, trying increasing these (see `delay*` variables, below).
* `SplitView` uses `hw.window.filter` to try to ignore atypical windows (menu panes, etc.), which see.  Unrecognized non-standard windows may interfere with `SplitView`'s operation.
* If there is only a single space, `SplitView` creates _and does not remove_ a new, empty space for temporarily holding unwanted windows from the same application(s).  This space can safely be deleted, but will recur on future invocations.

Example config in you `~/.hammerspoon/init.lua`:
```
mash =      {"ctrl", "cmd"}
spoon.splitView=hs.loadSpoon("SplitView")
spoon.splitView:bindHotkeys({choose={mash,"s"},
                             switchFocus={mash,"x"},
                             chooseAppEmacs={mash,"e","Emacs"})
```

To install, just download and double-click!
See [the docs]() for complete information on configuring `SplitView`.
