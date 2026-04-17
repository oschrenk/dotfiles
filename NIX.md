# nix-darwin

macOS system configuration via [nix-darwin](https://github.com/nix-darwin/nix-darwin).

## Structure

```
nix/
  flake.nix           — entry point, wires together all host configs
  modules/common.nix  — shared configuration across all machines
  hosts/maxbook.nix   — MaxBook-specific configuration
```

## First apply

Run once to bootstrap nix-darwin (before `darwin-rebuild` is available):

```bash
sudo nix run nix-darwin -- switch --flake "$(dirname $(chezmoi source-path))/nix#$(hostname -s)"
```

```fish
sudo nix run nix-darwin -- switch --flake (dirname (chezmoi source-path))"/nix#"(hostname -s)
```

## Subsequent applies

```bash
darwin-rebuild switch --flake "$(dirname $(chezmoi source-path))/nix#$(hostname -s)"
```

```fish
darwin-rebuild switch --flake (dirname (chezmoi source-path))"/nix#"(hostname -s)
```

## Formatting

Uses [nixfmt](https://github.com/NixOS/nixfmt) (the official Nix formatter, aliased as `nixfmt-rfc-style` in nixpkgs).

Must be run from the `nix/` directory — `nix fmt` requires a `flake.nix` in the current directory. Use the task runner from the repo root:

```sh
task nix-fmt
```

## Adding a new machine

1. Create `hosts/<machine>.nix` with at least `system.stateVersion`
2. Add an entry to `darwinConfigurations` in `flake.nix`
3. Run the first apply command above on that machine

## Known warnings

- `$HOME is not owned by you` — expected when running with `sudo`; nix-darwin switches to `/var/root` as home. Safe to ignore.

## Notes

- `system.stateVersion` — set once to the nix-darwin version at first apply, never change it
  - Check current version: `nix run nix-darwin -- --version`
  - See: https://github.com/nix-darwin/nix-darwin/blob/master/CHANGELOG.md
- `nixpkgs-unstable` — used to avoid nix-darwin modules breaking on missing nixpkgs features
- All changes are applied via `darwin-rebuild switch`, analogous to `chezmoi apply`

## Home Manager

User-level configuration via [home-manager](https://github.com/nix-community/home-manager), integrated into nix-darwin so `darwin-rebuild switch` applies both system and user config in one step.

### Structure

```
nix/
  modules/home-manager.nix  — wires HM into nix-darwin, derives username from system.primaryUser
  modules/home/
    default.nix             — entry point: home.username, home.homeDirectory, home.stateVersion
    git.nix                 — programs.git + programs.delta (aliases, lfs, ignores, attributes)
    starship.nix            — programs.starship
    atuin.nix               — programs.atuin
```

### What HM manages

| Tool | Binary | Config |
|------|--------|--------|
| git + delta + git-lfs | nixpkgs (via HM) | `modules/home/git.nix` |
| starship | nixpkgs (via HM) | `modules/home/starship.nix` |
| atuin | nixpkgs (via HM) | `modules/home/atuin.nix` |

chezmoi remains responsible for secrets, neovim, fish, and anything requiring direct editing.

### Supported programs

HM has `programs.<name>` modules for these tools (among many others):

```
atuin  bat  direnv  fish  fzf  gh  git  htop  jq  neovim  ripgrep  starship  tmux  zoxide
```

Full list: https://home-manager-options.extranix.com — search by program name.

Tools without a HM module can still be managed via `home.file` for stable, secret-free configs.

### Notes

- `home.stateVersion` — set once to the HM version at first apply, never change it. Tells HM which backwards-incompatible state migrations to skip.

## Pinning and updating packages

All package versions are pinned by `nix/flake.lock`. To update:

```fish
# Update all inputs to their latest commits
cd nix && nix flake update

# Update a single input (e.g. nixpkgs only)
cd nix && nix flake update nixpkgs

# Then apply
task nix
```

To pin an input to a specific commit (e.g. for a known-good nixpkgs):

```nix
# in flake.nix
nixpkgs.url = "github:NixOS/nixpkgs/abc123def456";
```

Commit `flake.lock` after updates so the pinned state is reproducible across machines.

## Dev Shells

Per-project development environments via [nix-direnv](https://github.com/nix-direnv/nix-direnv).

### Basic setup

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

Add `use flake` to `.envrc` or `.envrc.local`. First activation downloads packages; subsequent ones are instant from cache.

### For company repos (can't commit flake.nix)

Add to local gitignore (not committed):

```bash
echo "flake.nix" >> .git/info/exclude
echo "flake.lock" >> .git/info/exclude
```

### Symlinked flake.nix (via infuse)

Nix resolves symlinks and checks git tracking against the wrong repo, causing:

```
error: Path '.../flake.nix' does not exist in Git repository "/path/to/project"
```

Workaround — resolve the symlink before passing to nix in `.envrc.local`:

```bash
use flake "$(dirname $(readlink -f ./flake.nix))"
```

This points nix at the infuse-managed repo where `flake.nix` is actually tracked.
