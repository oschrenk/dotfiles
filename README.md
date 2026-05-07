# README

These are my dotfiles.

## Bootstrap

Name machine first — `hostname` is used by `nix-darwin` and `chezmoi` templating

```sh
./scripts/hostname.sh
```

Then install Nix, Homebrew, and chezmoi

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

Create the machine-local identity file (name, email, SSH key, timezone — never committed):

```sh
task nix-setup-identity
```

Once the nix-darwin flake is set up, apply it with

```sh
sudo nix run nix-darwin -- switch --flake "~/nix#$(hostname -s)"
```

Subsequent runs use

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

Initialize chezmoi (requires `task nix-max` to have run first so home-manager has written `~/.local/share/identity/data.toml`):

```
chezmoi init oschrenk/dotfiles
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
