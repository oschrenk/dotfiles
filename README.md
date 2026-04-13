# README

These are my dotfiles.

## Bootstrap

Name machine first — `hostname` is used by `nix-darwin` and `chezmoi` templating

```sh
./hostname.sh
```

Then install Nix, Homebrew, and chezmoi

```sh
./bootstrap.sh
```

## nix-darwin

Once the nix-darwin flake is set up, apply it with

```sh
sudo nix run nix-darwin -- switch --flake "~/nix#$(hostname -s)"
```

Subsequent runs use

```sh
darwin-rebuild switch --flake "~/nix#$(hostname -s)"
```

Setup 1Password and sync the vaults, then initialize chezmoi

```
chezmoi init oschrenk/dotfiles
```

Certain files require age decryption. You will be asked a few questions.

These answers are stored in 1Password under
- "Chezmoi / Age / Key" and
- "Meli / Personal / Oauth"

```
Age identity file location?
Age public key?
...
Personal Google OAuth Client ID?
```

Pull binary assets

```
chezmoi cd
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
  - log into iCloud if needed
- 1Password
  - Security > Touch Id
  - Security > Apple Watch.
  - Developer > Use the SSH Agent
  - Developer > Enable Biometric Unlock
- Ghostty
  - SystemSettings > "Privacy & Security > Full disk access..." Allow for ...
- Arc
  - open profiles, and log into services
- Atuin
  - `atuin login`
- Karabiner Elements.
  - Open. Read "System Extensions Blocked" popup. Click on "Open Security Preferences" and press "Allow".
- IntelliJ.
  - Configure plugins.
    - AutoDarkMode
    - Harpooner
    - Hocon
    - Ideavim
    - Key Promoter
    - Kotlin
    - Scala
  - Change settings
    - Don't send statistics
- Photos
  - Open to synchronize data
- Spotify
  - download "Liked Songs"
- sketchybar
  - `brew services start sketchybar`

Login:
- Discord
- Slack

Link device:
- Signal
- Telegram
- Whatsapp

## Setup git projects

Setup all git projects

* requires ssh key (via 1Password)
* requires `arbol`

```
mkdir ~/Projects
arbol sync
```

## Scoped runs

- `task brew` Install taps/brews/apps
- `task cargo` Install crates
- `task extensions` Install Arc Browser extensions
- `task go` Install go apps
- `task icons` Install icons
- `task lua` Install lua rocks
- `task node` Install node tools
- `task ollama` Install ollama models

## Steam & Rosetta

`brew install steam`

Steam is the last application (I use) not offering a native arm variant for macOS

```
# install rosetta 2
# system_profiler SPApplicationsDataType -json | jq -r '.SPApplicationsDataType[] | select (.arch_kind == "arch_i64") | ._name ' | sort
#
# needed for
#   Steam
#   Steam Helper
softwareupdate --install-rosetta --agree-to-license
```
