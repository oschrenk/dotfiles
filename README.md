# README

These are my dotfiles.

## Bootstrap

The `nix/` flake and `scripts/` live in this repo, so clone it first. The repo
is public, so clone over HTTPS (the SSH key is provisioned later via 1Password).
Clone into chezmoi's source directory so a single checkout serves as both the
flake root and the chezmoi source:

```sh
# git ships with the Xcode Command Line Tools; this triggers their install
xcode-select --install

git clone https://github.com/oschrenk/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi
```

Name the machine next (`hostname` is used by `nix-darwin` and `chezmoi` templating):

```sh
./scripts/hostname.sh
```

Then install Nix and Homebrew (chezmoi itself is installed later by nix-darwin):

```sh
./scripts/bootstrap.sh
```

## nix-darwin

Configure `/etc/nix/nix.custom.conf` (Determinate Nix preserves this across upgrades):

```sh
echo 'trusted-users = oliver' | sudo tee -a /etc/nix/nix.custom.conf
echo 'extra-substituters = https://nixos-raspberrypi.cachix.org' | sudo tee -a /etc/nix/nix.custom.conf
echo 'extra-trusted-public-keys = nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI=' | sudo tee -a /etc/nix/nix.custom.conf
sudo launchctl kickstart -k system/systems.determinate.nix-daemon
```

Identity values (name, email, SSH key, timezone) live in the committed
`nix/identity.nix`, so nothing is needed here on your own machines. When forking
or changing them, edit `nix/identity.nix` directly, or run `task nix-setup-identity`
(available after the first apply below, since `task` is installed by nix-darwin).

**Before the first apply, grant Terminal Full Disk Access.** Without it,
activation cannot write the TCC-protected `com.apple.universalaccess` domain, the
switch aborts, and your login shell is left pointing at a fish that is not
installed yet (a dead terminal). On a fresh machine the switch runs in
Terminal.app (Ghostty is not installed yet), so:

- System Settings > Privacy & Security > Full Disk Access > enable Terminal
- Quit Terminal (Cmd-Q) and reopen

Apply the flake. `task` is not on PATH yet (go-task comes from nix-darwin), and
the flake is in the `nix/` subdirectory, so run it directly from the repo root:

```sh
sudo nix run nix-darwin -- switch --flake "./nix#$(hostname -s)"
```

If the switch ever does abort on `universalaccess` and breaks your shell, set
Terminal to open `/bin/zsh` directly (Settings > General > "Shells open with")
to recover, grant Full Disk Access, then re-run the switch.

Subsequent runs use the task wrapper:

```sh
task nix-max
```

## opnix bootstrap

Some secrets (currently the atuin sync key) are sourced from 1Password via
[opnix](https://github.com/brizzbuzz/opnix).
The bootstrap is per-machine and the
token never lands in git.

Service account is "Service Account / opnix-bootstrap"

Place the token at `/etc/opnix-token`:

```sh
sudo install -m 0600 -o root -g wheel /dev/null /etc/opnix-token
sudo $EDITOR /etc/opnix-token
```

kickstart service manually:

```sh
sudo launchctl kickstart -k system/org.nixos.opnix-secrets
```

Initialize chezmoi. The repo is already at chezmoi's source directory from the
bootstrap clone, so `chezmoi init` reuses it without re-downloading. This
requires `task nix-max` to have run first, so home-manager has written
`~/.local/share/identity/data.toml`:

```sh
chezmoi init
```

Pull binary assets (git-lfs is installed by nix-darwin):

```sh
git lfs install
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
  - The sync key is provisioned by opnix from 1Password (`Bootstrap` vault),
    so no key transfer between machines is needed. Run `atuin login` and
    enter username + password.
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
- `task node` Install node tools
- `task ollama` Install ollama models

## Troubleshooting

### Nix binary cache warnings ("ignoring untrusted substituter")

Binary caches defined in a flake's `nixConfig` are ignored unless the invoking user is trusted and `accept-flake-config` is set. The fix is to add the cache directly to `/etc/nix/nix.custom.conf` (which Determinate Nix preserves across upgrades) and restart the daemon:

```sh
echo 'extra-substituters = https://example.cachix.org' | sudo tee -a /etc/nix/nix.custom.conf
echo 'extra-trusted-public-keys = example.cachix.org-1:...' | sudo tee -a /etc/nix/nix.custom.conf
sudo launchctl kickstart -k system/systems.determinate.nix-daemon
```

---

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
