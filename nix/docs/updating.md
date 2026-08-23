# Updating Nix Inputs

All commands run from `nix/`.

## What Are Inputs?

The flake has five inputs declared in `flake.nix`:

| Input | What it is |
|-------|------------|
| `nixpkgs` | The main package collection (nixpkgs-unstable). Used by the Mac and is the source for most packages. |
| `nix-darwin` | macOS system configuration framework. |
| `home-manager` | User environment configuration. |
| `nixos-raspberrypi` | RPi-specific kernel, firmware, and system modules. Has its own nixpkgs pin (separate from ours). |
| `opnix` | 1Password secrets integration for NixOS. |

Each input is pinned to a specific commit in `flake.lock`.
Nothing changes unless you explicitly update.

## Updating Inputs

Update one input:

```sh
nix flake update nixpkgs
nix flake update nix-darwin
nix flake update nixos-raspberrypi
```

Update everything at once:

```sh
nix flake update
```

After updating, deploy the affected hosts to apply the changes.

Commit `flake.lock` afterwards so every machine builds from the same pins.

## Pinning an Input to a Commit

To hold an input at a known-good revision, put the commit in its URL:

```nix
# in flake.nix
nixpkgs.url = "github:NixOS/nixpkgs/abc123def456";
```

## `nixos-raspberrypi` Has Its Own `nixpkgs`

`nixos-raspberrypi` bundles its own nixpkgs pin (separate from ours).
This is the nixpkgs used for the Pi builds - the RPi kernel and firmware are built against it.

When you run `nix flake update nixos-raspberrypi`, you get the latest commit of the nixos-raspberrypi project.
That commit may have advanced its own nixpkgs pin.
You are not choosing the nixpkgs version - you get whatever the nixos-raspberrypi maintainer last tested.

Check which nixpkgs a Pi host is actually using:

```sh
nix eval '.#nixosConfigurations.pi-2.pkgs.path' --raw
```

## `follows` For Darwin Vs Pi

`nix-darwin` and `home-manager` both already use `follows = "nixpkgs"` in `flake.nix`.
This is safe for the Mac because there is no kernel involved - all packages come from the binary cache and nothing needs to recompile when nixpkgs changes.

```nix
nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
home-manager.inputs.nixpkgs.follows = "nixpkgs";
```

Do NOT add `follows` for `nixos-raspberrypi`. nixos-raspberrypi's kernel patches were built and cached against its own nixpkgs pin.
Switching that pin invalidates the binary cache and forces a full RPi kernel recompile on the Pi - which takes hours.
If a specific package in nixos-raspberrypi's nixpkgs is outdated, use a surgical overlay instead (see below).

## Surgical Package Overrides

If a specific package in nixos-raspberrypi's nixpkgs is outdated or insecure, override just that package via `nixpkgs.overlays` instead of updating the whole nixpkgs:

```nix
# In the affected module:
nixpkgs.overlays = [
  (_final: _prev: {
    somePackage = (import nixpkgs { inherit (pkgs) system; }).somePackage;
  })
];
```

This keeps the RPi kernel on its tested pin while pulling a specific package from a newer nixpkgs.

## Checking Current Pins

```sh
# Show all current input revisions
nix flake metadata

# Show the nixpkgs commit used by a specific host
nix eval '.#nixosConfigurations.pi-2.config.system.nixpkgs.revision' --raw 2>/dev/null
```
