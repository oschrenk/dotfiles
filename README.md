# README

These are my dotfiles. There are many like it but these are mine.

## Install new machine

Install homebrew and bootstrap requirements

```
# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# temporary setup path in zsh until we have fish
eval "$(/opt/homebrew/bin/brew shellenv)"

# install chezmoi and requirements
brew install chezmoi git git-lfs age 1password 1password-cli
```

Setup 1Password and sync the vaults.

Initialize chezmoi.

```
chezmoi init oschrenk/dotfiles
```

Certain files require age decryption. You will be asked a few questions.
These answers are stored in 1Password under "Chezmoi / Age / Key"

```
Age identity file location?
Age public key?
```

Pull binary assets

```
chezmoi cd
git lfs install
git lfs pull
```

Apply

```
chezmoi apply
```

## First run

Follow the on-screen instructions. You will sometimes be asked for a password.
Downloading and compiling all the various applications and packages will take roughly 1 hour.

After casks are installed you can already start important apps and configure them

- App Store
- 1Password
  - Security > Touch Id
  - Security > Apple Watch.
  - Developer > Use the SSH Agent
  - Developer > Enable Biometric Unlock
- Alacritty
  - SystemSettings > "Privacy & Security > Full disk access..." Allow for ...
- Arc
  - open profiles, and log into services
- Hammerspoon
  - Preferences. Apply accessibility settings.
- Karabiner Elements.
  - Open. Read "System Extensions Blocked" popup. Click on "Open Security Preferences" and press "Allow".
- IntelliJ. Configure plugins.
  - Scala
  - Key Promoter
  - Ideavim
  - Hocon
- Photos
  - Open to synchronize data
- Spotify
  - download "Liked Songs"

Login:

- Discord
- Slack

Link device:

- Signal
- Telegram
- Whatsapp

## Rosetta

Steam is one of the last applications not offering a native arm variant for macOS

```
# install rosetta 2
# system_profiler SPApplicationsDataType -json | jq -r '.SPApplicationsDataType[] | select (.arch_kind == "arch_i64") | ._name ' | sort
#
# needed for
#   Steam
#   Steam Helper
softwareupdate --install-rosetta --agree-to-license
```
