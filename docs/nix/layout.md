# Config Layout

## Directory Tree

```text
nix/
  flake.nix              - entry point; wires hosts to modules
  options.nix            - shared options.* namespace
  identity.nix           - committed; sets my.personal.* values
  setup-identity.sh      - script: prompts for identity.nix values (only needed when forking or identity changes)

  hosts/
    maxbook.nix          - darwin host
    pi-1.nix             - NixOS hosts: pi specific overrides
    pi-2.nix
    pi-3.nix

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
        server.nix       - server/homelab tools
      defaults/          - macOS preferences
        system/          - system-wide preferences
          [...]
        apps/            - app settings, one file per bundle ID
          [...]

    home/                - home-manager modules (user-level config)
      default.nix        - entry point: home.username, homeDirectory, stateVersion
      git.nix            - git + delta + lfs
      starship.nix       - prompt
      atuin.nix          - shell history

    nixos/               - NixOS modules for Raspberry Pis
      base.nix           - user settings, SSH, networking, timezone via my.personal.*
      pi4-hardware.nix   - RPi4-specific hardware config
      secrets.nix        - opnix secret management
      step-ca.nix        - local ACME CA (homelab-ca options)
      homelab.nix        - reverse proxy (traefik), apex + subdomain routes
      glance.nix         - homelab dashboard (serves the apex)
      adguard.nix        - DNS / ad blocking
      gatus.nix          - health checks
      beszel/
        hub.nix          - monitoring hub
        agent.nix        - monitoring agent
      restic/
        adguard.nix      - backup: adguard data
        beszel.nix       - backup: beszel data
        healthcheck.nix  - backup completion notifications
        step-ca.nix      - backup: step-ca keys and config

  docs/
    architecture.md      - physical homelab: hardware, network, DNS
    layout.md            - this file: how nix/ is organised
    darwin.md            - applying config on macOS
    builder.md           - aarch64-linux VM for cross-building
    secrets.md           - 1Password secrets via opnix
    updating.md          - flake inputs and pins
    cleanup.md           - reclaiming disk space
```

## Identity Namespace: `options.my.personal.*`

All identity values flow through a single shared namespace declared in `options.nix` and set in `identity.nix`:

| Option | Type | Used by |
|--------|------|---------|
| `my.personal.username` | str | `shell.nix`, `home-manager.nix`, `home/default.nix`, `nixos/base.nix` |
| `my.personal.name` | str | `home/git.nix` |
| `my.personal.email` | str | `home/git.nix` |
| `my.personal.timezone` | str | `nixos/base.nix` |
| `my.personal.sshKey` | str | `nixos/base.nix` |

`my.personal.*` is deliberately namespaced to leave room for future areas: `my.work.*`, `my.homelab.*`, etc.

## `identity.nix`

`identity.nix` holds personal identity values (name, email, SSH public key, timezone, username) used across all hosts.
It is:

- Committed to the repo.
  None of these values are secret.
  They already appear in the author line of every commit and on `github.com/<user>.keys`.
- The only file that needs editing on identity changes (job change, key rotation)
- Optionally regenerated via `task nix:setup:identity` (interactive prompts with sensible defaults)

If you fork this repo, edit `identity.nix` directly or run `task nix:setup:identity` to fill in your values.

## Pattern

This configuration follows the [Dendritic pattern](https://discourse.nixos.org/t/the-dendritic-pattern/61271) ([reference repo](https://github.com/mightyiam/dendritic)): modules are organised by **feature/domain** rather than by infrastructure type.
It is [Domain-Driven Design](https://en.wikipedia.org/wiki/Domain-driven_design) applied to Nix.
One file configures each concern (shell, git, secrets, backup), whether that concern applies to macOS or NixOS.

The alternative, grouping by layer (`darwin/`, `home/`, `homelab/`), forces you to scatter a single feature's config across multiple directories.
The dendritic approach keeps related things together and makes the "what does this machine do?" question answerable by reading a flat module list.

**Pragmatic deviations**: this configuration makes two deliberate compromises.

First, `darwin/` and `nixos/` are platform boundaries rather than feature boundaries.
Strictly dendritic would have one `shell.nix` configuring fish across both darwin and NixOS, with platform guards inside the file.
Platform-specific concerns (Homebrew, PAM, macOS preferences) are hard or impossible to share, so the platform directories are kept as a trade-off: they violate the "one file per feature" ideal but avoid the complexity of mixing darwin and NixOS expressions inside a single module.

Second, within `nixos/`, related files are grouped into subdirectories by tool (`beszel/`, `restic/`) rather than by capability.
Strictly dendritic would have a flat `monitoring.nix` or a `backup.nix` that owns everything.
The subdirectory grouping is not dendritic.
It sorts by tool rather than by capability, but it keeps related files together and makes the layout readable at a glance.
