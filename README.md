# README #

These are my dotfiles. There are many like it but these are mine.

## Install new machine

```
# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install chezmoi and requirements
brew install chezmoi git git-lfs

# init
chezmoi init oschrenk/dotfiles

# pull assets
chezmoi cd
git lfs install
git lfs pull
```

### Packages

Follow the on-screen instructions. You will sometimes be asked for a password.
Downloading and compiling all the various applications and packages will take roughly 1 hour.

After casks are installed you can already start important apps and configure them

- App Store, Press continue.
- 1Password.
  - Let it sync.
  - Security > Touch Id
  - Security > Apple Watch.
  - Developer > Use the SSH Agent
  - Developer > Biometric Unlock
- Chrome.
  - Grammarly
  - Instapaper
- Karabiner Elements.
  - Open. Read "System Extensions Blocked" popup. Click on "Open Security Preferences" and press "Allow".
- Bear
  - Synchronize
- Noteplan.
  - Settings > Sync > Use cloudkit
  - Leave open to sync
- IntelliJ. Configure plugins.
  - Scala,
  - Key Promoter
  - Ideavim
  - Hocon
- Hammerspoon.
  - Preferences. Apply accessibility settings.
- alacritty.
  - System Preferences > Security & privacy > General. Click Allow.
- Calendar
- Mail
- Photos. Sync, stay with power cable
- Spotify
- Raycast

