# README.md

## Workspaces

###  Multiple monitors

- The pool of workspaces is shared between monitors
- Each monitor shows its own workspace. The showed workspaces are called"visible" workspaces
- Different monitors can’t show the same workspace at the same time
- Each workspace (even invisible, even empty) has a monitor assigned to it
- By default, all workspaces are assigned to the "main" monitor ("main" as in System → Displays → Use as)

## Disable ‘Displays have separate Spaces’

You can disable the setting by running:

```
defaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer
```

(or in System Settings: System Settings → Desktop & Dock → Displays have separate Spaces). Logout is required for the setting to take effect.

See https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
