# README #

These are my dotfiles. There are many like it but these are mine.

## Install new machine

```
# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# temporary setup path in zsh until we have fish
eval "$(/opt/homebrew/bin/brew shellenv)"

# install chezmoi and requirements
brew install chezmoi git git-lfs

# install rosetta 2
softwareupdate --install-rosetta

# init
chezmoi init oschrenk/dotfiles
chezmoi cd
git lfs install
git lfs pull

# apply
chezmoi apply
```

### Packages

Follow the on-screen instructions. You will sometimes be asked for a password.
Downloading and compiling all the various applications and packages will take roughly 1 hour.

After casks are installed you can already start important apps and configure them

- App Store
- 1Password
  - Security > Touch Id
  - Security > Apple Watch.
  - Developer > Use the SSH Agent
  - Developer > Enable Biometric Unlock
- Chrome
  - open profiles, and log into services
- Karabiner Elements.
  - Open. Read "System Extensions Blocked" popup. Click on "Open Security Preferences" and press "Allow".
- IntelliJ. Configure plugins.
  - Scala
  - Key Promoter
  - Ideavim
  - Hocon
- Hammerspoon
  - Preferences. Apply accessibility settings.
- alacritty
  - System Preferences > Security & privacy > General. Click Allow.
- Calendar
- Mail
- Spotify
  - download "Liked Songs"

System Settings:
- "Privacy & Security > Full disk access..." Allow for alacritty. Otheriwse you will see

Open these apps to start synchronizing data
- Bear
- Noteplan
- Photos

Link device:
- Signal
- Telegram
