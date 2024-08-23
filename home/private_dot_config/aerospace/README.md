# README.md

```
brew install --cask nikitabobko/tap/aerospace
```

## Configuration

**Config samples**
Please see the following config samples:

- [i3 like config](https://nikitabobko.github.io/AeroSpace/goodness#i3-like-config)
- [Search for configs on GitHub](https://github.com/search?q=path%3A*aerospace.toml&type=code)

## Workspaces

###  Multiple monitors
- The pool of workspaces is shared between monitors
- Each monitor shows its own workspace. The showed workspaces are called"visible" workspaces
- Different monitors can’t show the same workspace at the same time
- Each workspace (even invisible, even empty) has a monitor assigned to it
- By default, all workspaces are assigned to the "main" monitor ("main" as in System → Displays → Use as)

###


## Disable ‘Displays have separate Spaces’
You can disable the setting by running:

```
defaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer
```

(or in System Settings: System Settings → Desktop & Dock → Displays have separate Spaces). Logout is required for the setting to take effect.

See https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
