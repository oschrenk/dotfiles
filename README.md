# README

These are my dotfiles.

## Bootstrap

Clone the repo to `/Users/<username>/Projects/ops/dotfiles`, the path that `my.host.dotfiles` in `nix/host.nix` names.
home-manager links the config trees out of that checkout.
Each stage script checks that the Mac is ready for it.
When the Mac is not ready, the script prints what is missing and stops, so you fix that and run it again.

1. Install the Xcode Command Line Tools, which include git: `xcode-select --install`
2. Clone the repo over HTTPS and enter it: `git clone https://github.com/oschrenk/dotfiles.git ~/Projects/ops/dotfiles && cd ~/Projects/ops/dotfiles`
3. Name the Mac and install Nix, Homebrew and 1Password: `./scripts/stage-01-install.sh`
4. Run the first switch after the preparation below: `./scripts/stage-02-switch.sh`
   - In 1Password, sign in and let it sync.
     Then enable Settings > Developer > "Use the SSH agent" and "Integrate with 1Password CLI".
   - In System Settings > Privacy & Security > Full Disk Access, enable Terminal.
     Then quit Terminal and open it again.
   - The first switch downloads and builds everything, which takes about an hour.
   - If the switch stops at `universalaccess` and the shell no longer opens, set Terminal > Settings > General > "Shells open with" to `/bin/zsh`.
     Then grant Full Disk Access and run the script again.
5. In a new terminal, fetch the LFS files and the infuse data: `./scripts/stage-03-finish.sh`

Then set up the apps by hand, with the checklist in [docs/first-run.md](docs/first-run.md).
Later changes apply with `task nix:rebuild:darwin`.

## Setup Git Projects

Setup all git projects

- requires ssh key (via 1Password)
- requires `arbol`

```text
mkdir ~/Projects
arbol sync
```

## Scoped Runs

- `task brew` Install the taps, brews and apps
- `task cargo` Install the crates
- `task customize:extensions` Install the Arc Browser extensions
- `task go` Install the go apps
- `task icons` Install the icons
- `task node` Install the node tools
- `task ollama` Install the ollama models

## Troubleshooting

### Nix Binary Cache Warnings ("Ignoring Untrusted Substituter")

Nix ignores the binary caches in a flake's `nixConfig` unless the invoking user is a trusted user and `accept-flake-config` is on.
The fix is to add the cache directly to `/etc/nix/nix.custom.conf` (which Determinate Nix preserves across upgrades) and restart the daemon:

```sh
echo 'extra-substituters = https://example.cachix.org' | sudo tee -a /etc/nix/nix.custom.conf
echo 'extra-trusted-public-keys = example.cachix.org-1:...' | sudo tee -a /etc/nix/nix.custom.conf
sudo launchctl kickstart -k system/systems.determinate.nix-daemon
```
