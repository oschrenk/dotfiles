# `nix-darwin`

macOS system configuration via [nix-darwin](https://github.com/nix-darwin/nix-darwin).

## Structure

```text
nix/
  flake.nix           entry point, wires together all host configs
  modules/common.nix  shared configuration across all machines
  hosts/maxbook.nix   MaxBook-specific configuration
```

## First Apply

Run once to bootstrap nix-darwin (before `darwin-rebuild` is available):

```bash
sudo nix run nix-darwin -- switch --flake "$(dirname $(chezmoi source-path))/nix#$(hostname -s)"
```

```fish
sudo nix run nix-darwin -- switch --flake (dirname (chezmoi source-path))"/nix#"(hostname -s)
```

## Subsequent Applies

```bash
darwin-rebuild switch --flake "$(dirname $(chezmoi source-path))/nix#$(hostname -s)"
```

```fish
darwin-rebuild switch --flake (dirname (chezmoi source-path))"/nix#"(hostname -s)
```

## Secrets

Secrets come from 1Password at activation, via opnix.
`scripts/stage-02-switch.sh` writes `/etc/opnix-token` from 1Password on a new Mac, and a missing token fails silently.

See [secrets.md](secrets.md).

## Formatting

Uses [nixfmt](https://github.com/NixOS/nixfmt) (the official Nix formatter, aliased as `nixfmt-rfc-style` in nixpkgs).

Must be run from the `nix/` directory, since `nix fmt` requires a `flake.nix` in the current directory.
Use the task runner from the repo root:

```sh
task nix:fmt
```

## Adding a New Machine

1. Create `hosts/<machine>.nix` with at least `system.stateVersion`
2. Add an entry to `darwinConfigurations` in `flake.nix`
3. Run the first apply command above on that machine

## Linux Builder

`aarch64-linux` builds, including the homelab Pi closures, run in an Apple `container` configured in `modules/darwin/container.nix`.

The repo declares three things:

- `services.containerization.linux-builder.aarch64.enable = true`, which installs the SSH key to `~/.ssh/nix-builder_ed25519` and stops activation deleting it
- the system-wide SSH alias `/etc/ssh/ssh_config.d/100-nix-builder-aarch64.conf`, pointing `nix-builder-aarch64` at `localhost:31022`
- the `builders` line in `nix.custom.conf`, because `nix.buildMachines` is inert under Determinate Nix

It does not declare the container.
This repo forces `autoStart` off, so no launchd agent exists and nothing creates the container.

Every `darwin-rebuild switch` destroys it.
Activation restarts the container runtime, which stops the container.
Activation then runs `container prune`, which removes every stopped container.
Volumes carry the builder's store across that, so a recreate downloads nothing.

Create the volumes once:

```bash
container volume create nix-builder-store
container volume create nix-builder-var
```

Seed them from the image before the first use, and again after the image changes.
Apple's runtime never copies image content into a fresh volume.
An unseeded volume hides `/nix/store`, and the container then lacks even `sh`.
Stop the builder first, because a volume attaches to one container at a time:

```bash
container run --rm \
  --volume nix-builder-store:/mnt/store --volume nix-builder-var:/mnt/var \
  --entrypoint sh ghcr.io/halfwhey/nix-builder:v2-nix2.35.4 \
  -c 'cp -an /nix/store/. /mnt/store/ && cp -an /nix/var/. /mnt/var/'
```

Then create the container, taking the image from `services.containerization.linux-builder.image`:

```bash
container run -d --name nix-builder-aarch64 \
  --volume nix-builder-store:/nix/store --volume nix-builder-var:/nix/var \
  --publish 127.0.0.1:31022:22 \
  --cpus 4 --memory 8g \
  ghcr.io/halfwhey/nix-builder:v2-nix2.35.4
```

Nothing reconciles that command against the option.
A module update that bumps the image leaves the container on the old one, so re-read the option before a recreate.

Use `container stop nix-builder-aarch64` when idle and `container start nix-builder-aarch64` before a build.
A stop leaves no process and no bound port.

Neither flag is a preference:

- `--publish 127.0.0.1:` bounds the exposure.
  Without the host IP the port binds every interface, and the public `nix-apple-container` repository holds the matching private key.
- `--memory 8g` sets a ceiling rather than a reservation, so an idle container costs nothing.
  Perses needs that ceiling.
  3072 kills its frontend build.

The module's launchd agent would otherwise hand the builder an empty store.
It runs `container stop` and `container rm` before every `container run`.
The runtime keeps `/nix/store` in the container's writable layer, so that `rm` discards it.

The homelab repo's `docs/builder.md` and its `nix:builder:*` tasks still describe the retired QEMU VM.
LAB-156 tracks the rewiring.

## Known Warnings

- `$HOME is not owned by you`.
  Expected under `sudo`, where nix-darwin switches to `/var/root` as home.
  Safe to ignore.
- `nix-apple-container: linux-builder is enabled but neither nix.enable nor the determinateNix module is available`.
  Expected: `nix.enable = false` under Determinate Nix, and Determinate's own nix-darwin module is not an input.
  The builder list goes into `nix.custom.conf` instead, so nothing is missing.

## Notes

- `system.stateVersion` is set once to the nix-darwin version at first apply.
  Never change it.
  - Check current version: `nix run nix-darwin -- --version`
  - See: <https://github.com/nix-darwin/nix-darwin/blob/master/CHANGELOG.md>
- `nixpkgs-unstable` keeps nix-darwin modules from breaking on missing nixpkgs features
- Changes apply via `darwin-rebuild switch`, analogous to `chezmoi apply`

## Home Manager

User-level configuration via [home-manager](https://github.com/nix-community/home-manager), integrated into nix-darwin so `darwin-rebuild switch` applies both system and user config in one step.

### Structure

```text
nix/
  modules/home-manager.nix  — wires HM into nix-darwin, derives username from system.primaryUser
  modules/home/
    default.nix             — entry point: home.username, home.homeDirectory, home.stateVersion
    git.nix                 — programs.git + programs.delta (aliases, lfs, ignores, attributes)
    starship.nix            — programs.starship
    atuin.nix               — programs.atuin
```

### What HM Manages

| Tool | Binary | Config |
|------|--------|--------|
| git + delta + git-lfs | nixpkgs (via HM) | `modules/home/git.nix` |
| starship | nixpkgs (via HM) | `modules/home/starship.nix` |
| atuin | nixpkgs (via HM) | `modules/home/atuin.nix` |

chezmoi remains responsible for secrets, neovim, fish, and anything requiring direct editing.

### Supported Programs

HM has `programs.<name>` modules for these tools (among many others):

```text
atuin  bat  direnv  fish  fzf  gh  git  htop  jq  neovim  ripgrep  starship  tmux  zoxide
```

Full list: <https://home-manager-options.extranix.com> (search by program name).

Tools without a HM module can still be managed via `home.file` for stable, secret-free configs.

### Notes

- `home.stateVersion` is set once to the HM version at first apply.
  Never change it: it tells HM which backwards-incompatible state migrations to skip.

## Pinning and Updating Packages

`nix/flake.lock` pins every input.
See [updating.md](updating.md).

## Dev Shells

Per-project development environments via [nix-direnv](https://github.com/nix-direnv/nix-direnv).

### Basic Setup

Add a `flake.nix` to the project:

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    {
      devShells.aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.mkShell {
        packages = with nixpkgs.legacyPackages.aarch64-darwin; [
          kotlin
          ktfmt
          ktlint
        ];
      };
    };
}
```

Add `use flake` to `.envrc` or `.envrc.local`.
First activation downloads packages.
Later ones are instant from cache.

### For Company Repos (Can't Commit `flake.nix`)

Add to local gitignore (not committed):

```bash
echo "flake.nix" >> .git/info/exclude
echo "flake.lock" >> .git/info/exclude
```

### Symlinked `flake.nix` (Via `infuse`)

Nix resolves symlinks and checks git tracking against the wrong repo, causing:

```text
error: Path '.../flake.nix' does not exist in Git repository "/path/to/project"
```

Workaround: resolve the symlink before passing to nix in `.envrc.local`:

```bash
use flake "$(dirname $(readlink -f ./flake.nix))"
```

This points nix at the infuse-managed repo where `flake.nix` is actually tracked.
