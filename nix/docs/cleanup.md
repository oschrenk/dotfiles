# Cleaning Up Disk Space

NixOS keeps every previous system generation in `/nix/store` until you explicitly garbage-collect. On a host with limited storage (e.g. a Pi on a USB stick), the store can balloon to many GB of unreachable paths from old generations, cancelled builds, and one-off package installs.

## Free up space

Run on the host that's tight on space:

```sh
sudo nix-collect-garbage -d
```

This removes every store path not referenced by the *current* system: old generations, dangling GC roots, build-time-only dependencies. After it finishes, any rollback to a previous generation is gone, but the running system is untouched.

## Inspect where the bytes are

```sh
sudo du -sh /nix/store /var/lib /home /tmp /var/tmp 2>/dev/null
```

`/nix/store` shrinks dramatically after `nix-collect-garbage -d`. If `/var/lib/*` or `/home/*` is still large, the leftover state belongs to a service that's been removed from the config but whose data directory wasn't cleaned up (e.g. a previous experiment with MongoDB, UniFi, etc.). Those need manual `rm -rf`.

## Automatic GC on the Pis

The Pis run `nix-collect-garbage` weekly via `nix.gc.automatic` in `modules/nixos/base.nix`, with `--delete-older-than 14d` as the retention policy. Manual cleanup is only needed if you've just torn down a big service, are tight on space mid-week, or want to drop generations more aggressively than the schedule allows.

The Mac runs Determinate Nix (`nix.enable = false` in `modules/common.nix`), which manages its own daemon; nix-darwin's `nix.gc.*` options are disabled there, so manual GC remains the model on macOS.

## When to run it manually

- Before a deploy that's likely to pull in a lot of new closure (kernel update, big service rollout)
- Whenever a host reports >80% disk usage
- After ripping out a service whose state directory you've also removed

## Where it does NOT help

- Build cache misses (the *next* `nixos-rebuild` will repopulate the store)
- Anything outside `/nix/store` (service state, logs, journal). Those need targeted cleanup.
