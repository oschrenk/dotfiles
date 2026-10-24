# Config Layout

## Directory Tree

This repository builds the two Macs.

```text
nix/
  flake.nix              - entry point; wires hosts to modules
  options.nix            - options.my.host namespace
  host.nix               - sets my.host.dotfiles, the working-copy path both Macs share

  hosts/
    airbook.nix          - darwin hosts
    maxbook.nix

  pkgs/                  - Mac-side tools that download an upstream binary, because nixpkgs lacks them or lags;
                           tools built from source come from github:oschrenk/pkgs
    cottage.nix
    msgvault.nix           - mail archive
    [...]

  modules/
    common.nix           - shared settings across all machines
    shell.nix            - fish shell setup
    home-manager.nix     - wires HM into nix-darwin

    packages.nix         - nix system-level packages (eg. direnv)

    darwin/              - darwin-only modules
      brew/              - Homebrew packages, split by audience
        settings.nix     - Homebrew global settings
        base.nix         - base CLI packages
        fonts.nix        - font casks
        gui.nix          - general GUI apps
        work.nix         - work-specific apps
      defaults/          - macOS preferences
        system/          - system-wide preferences (nix-darwin)
          [...]
        user/            - per-user System Settings (nix-plist-manager), one file per pane
          [...]
        apps/            - app settings, one file per bundle ID
          [...]
      java.nix           - JDK selection
      nix.nix            - nix daemon and GC settings
      power.nix          - sleep on battery, awake on charger
      secrets.nix        - opnix secret directory ownership

    home/                - home-manager modules (user-level config), one per tool
      default.nix        - entry point: home.username, homeDirectory, stateVersion
      git.nix            - git + delta + lfs
      starship.nix       - prompt
      atuin.nix          - shell history
      [...]              - ~44 files; the directory listing is the index
```

The docs themselves live at the repo root, not under `nix/`:

```text
docs/
  atuin.md               - shell history sync
  nix/
    layout.md            - this file: how nix/ is organised
    darwin.md            - applying config on macOS
    secrets.md           - 1Password secrets via opnix
    updating.md          - flake inputs and pins
    cleanup.md           - reclaiming disk space
```

## Identity and Host Namespaces

Identity values live in the private flake `oschrenk/private.nix`.
Its `modules.identity` both declares and sets `my.personal.*` and `my.work.*`, and both hosts import it as `inputs.private.modules.identity`.
`options.nix` declares only `my.host.*`, and `host.nix` sets it.

| Option | Type | Set in | Used by |
|--------|------|--------|---------|
| `my.personal.username` | str | `modules.identity` | many modules; `rg 'my\.personal\.username' nix` lists them |
| `my.personal.name` | str | `modules.identity` | `home/git.nix` |
| `my.personal.email` | str | `modules.identity` | `scripts/bootstrap-infuse.sh` |
| `my.work.email` | str | `modules.identity` | nothing yet |
| `my.host.dotfiles` | str | `host.nix` | `home/claude.nix`, `home/fish.nix`, `home/nvim.nix`, `home/sketchybar.nix` |

## The Private Flake

`oschrenk/private.nix` holds values that are private but not secret, and the flake fetches it as `git+ssh://git@github.com/oschrenk/private.nix`.

- Its values are world-readable in the local Nix store once fetched.
  Secrets stay in 1Password and reach the hosts through opnix.
- The fetch runs as root during `task nix:rebuild:darwin` and goes through the 1Password SSH agent.
  `programs.ssh.knownHosts` in `modules/common.nix` declares GitHub's host key, so the fetch never stops at a prompt.
- A fresh Mac needs 1Password signed in with its SSH agent on before the first rebuild, because the flake cannot evaluate without the private input.
- This repo does not support forks.
  A checkout without access to `oschrenk/private.nix` does not evaluate.

## Pattern

This configuration follows the [Dendritic pattern](https://discourse.nixos.org/t/the-dendritic-pattern/61271) ([reference repo](https://github.com/mightyiam/dendritic)): modules are organised by **feature and domain** rather than by infrastructure type.
It is [Domain-Driven Design](https://en.wikipedia.org/wiki/Domain-driven_design) applied to Nix.
One file configures each concern (shell, git, secrets, backup), whether that concern applies to macOS or NixOS.

The alternative, grouping by layer (`darwin/`, `home/`), forces you to scatter a single feature's config across multiple directories.
The dendritic approach keeps related things together and makes the "what does this machine do?" question answerable by reading a flat module list.

**Pragmatic deviation**: this configuration makes one deliberate compromise.

`darwin/` is a platform boundary rather than a feature boundary.
Strictly dendritic would have one `shell.nix` configuring fish across both darwin and NixOS, with platform guards inside the file.
Platform-specific concerns (Homebrew, PAM, macOS preferences) are hard or impossible to share, so the platform directories are kept as a trade-off: they violate the "one file per feature" ideal but avoid the complexity of mixing darwin and NixOS expressions inside a single module.
