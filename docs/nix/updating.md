# Updating Nix Inputs

All commands run from `nix/`.

## What Are Inputs?

`flake.nix` declares these inputs:

| Input | What it is |
|-------|------------|
| `nixpkgs` | The main package collection (nixpkgs-unstable). Source for most packages. |
| `nix-darwin` | macOS system configuration framework. |
| `home-manager` | User environment configuration. |
| `opnix` | 1Password secrets integration. |
| `arbol`, `cutter`, `infuse`, … | Own tools, each building against the nixpkgs it locked, so the cachix cache keeps matching. |

Each input is pinned to a specific commit in `flake.lock`.
Nothing changes unless you explicitly update.

## Updating Inputs

Update one input:

```sh
nix flake update nixpkgs
nix flake update nix-darwin
```

Update everything at once:

```sh
nix flake update
```

Preview what an update would change before writing the lock:

```sh
task nix:update:preview
```

After updating, rebuild and commit `flake.lock`, so both Macs build from the same pins.

## Pinning an Input to a Commit

To hold an input at a known-good revision, put the commit in its URL:

```nix
# in flake.nix
nixpkgs.url = "github:NixOS/nixpkgs/abc123def456";
```

## `follows`

`nix-darwin` and `home-manager` both use `follows = "nixpkgs"`, so one nixpkgs serves all three.
This is safe on a Mac: no kernel is involved, and packages come from the binary cache.

```nix
nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
home-manager.inputs.nixpkgs.follows = "nixpkgs";
```

The own-tool inputs deliberately do NOT follow.
Each was built and cached on `oschrenk.cachix.org` against its own lock, and rebasing them onto our nixpkgs turns every rebuild into a Go compile.

## Checking Current Pins

```sh
nix flake metadata
```
