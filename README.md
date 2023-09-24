# README #

These are my dotfiles. There are many like it but these are mine.

## Install new machine

```
# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# temporary setup path in zsh until we have fish
eval "$(/opt/homebrew/bin/brew shellenv)"

# install chezmoi and requirements
brew install age chezmoi git git-lfs 1password

# install rosetta 2
# system_profiler SPApplicationsDataType -json | jq -r '.SPApplicationsDataType[] | select (.arch_kind == "arch_i64") | ._name ' | sort
#
# needed for
#   Steam
#   Steam Helper
softwareupdate --install-rosetta

# init
chezmoi init oschrenk/dotfiles
chezmoi cd
git lfs install
git lfs pull

# apply
chezmoi apply
```

Certain files require age decryption. You will be asked a few questions:

```
chezmoi init
Age identity file location?
Age public key?
```

These answers are stored in 1Password under "Chezmoi / Age / Key"

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
- Arc
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
- Spotify
  - download "Liked Songs"

System Settings:
- "Privacy & Security > Full disk access..." Allow for alacritty.
- Add and configure Internet accounts

Open these apps to start synchronizing data
- Bear
- Noteplan
- Photos

Login:
- Discord
- Grammarly Desktop
- Slack

Link device:
- Signal
- Telegram
- Whatsapp
