# Config Layout

## Directory Tree

This repository builds the two Macs.

```text
nix/
  flake.nix              - entry point; wires hosts to modules
  options.nix            - options.my.personal namespace
  identity.nix           - committed; sets my.personal.* values (Macs)
  secrets.nix            - secretspec reader, resolves op:// addresses from secretspec.toml
  setup-identity.sh      - script: prompts for identity.nix values (only needed when forking or identity changes)

  hosts/
    airbook.nix          - darwin hosts
    maxbook.nix

  pkgs/                  - Mac-side tools; packaged here because nixpkgs lacks them or lags
    cottage.nix            - own tools: msgvault (mail archive), tlink (tmux://
    msgvault.nix             deeplinks), gitwatch-rs, and others
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
        system/          - system-wide preferences
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

## Identity Namespace: `options.my.personal.*`

Mac-side identity values flow through a single namespace declared in `options.nix` and set in `identity.nix`:

| Option | Type | Used by |
|--------|------|---------|
| `my.personal.username` | str | `shell.nix`, `home-manager.nix`, `home/default.nix` |
| `my.personal.name` | str | `home/git.nix` |
| `my.personal.email` | str | `home/git.nix` |

## `identity.nix`

`identity.nix` holds personal identity values (name, email, SSH public key, timezone, username) for the Macs.
It is:

- Committed to the repo.
  None of these values are secret.
  They already appear in the author line of every commit and on `github.com/<user>.keys`.
- The only file that needs editing on identity changes (job change, key rotation)
- Optionally regenerated via `task nix:setup:identity` (interactive prompts with sensible defaults)

If you fork this repo, edit `identity.nix` directly or run `task nix:setup:identity` to fill in your values.

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
