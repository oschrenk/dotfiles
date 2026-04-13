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
