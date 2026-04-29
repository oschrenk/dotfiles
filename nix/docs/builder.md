# linux-builder: aarch64-linux VM on macOS

`pkgs.darwin.linux-builder` runs a QEMU/HVF aarch64-linux VM on macOS. Used to cross-compile packages for Raspberry Pi that are not cached (e.g. MongoDB 7.0 - SSPL license means Hydra skips it).

Config: `nix/modules/darwin/linux-builder.nix`

## How it works

`create-builder` sets up SSH keys, then calls `run-builder`, which calls `run-nixos-vm`. `run-nixos-vm` starts QEMU with a qcow2 disk at `/var/lib/linux-builder/nixos.qcow2`. The VM boots a minimal NixOS and exposes SSH on `localhost:31022`.

nix-darwin registers it as a launchd daemon (`system/org.nixos.linux-builder`) that starts on boot.

## Settings

```
QEMU_OPTS = "-smp 4 -m 16384"
```

`run-nixos-vm` hardcodes `-smp 1 -m 3072`. `QEMU_OPTS` is appended last so our values win - QEMU uses the last occurrence of each flag.

- 4 cores: MongoDB 7.0 compilation needs ~3-4GB RAM per parallel job. 8 jobs OOM'd at 11GB.
- 16GB: 4 cores x 4GB/job headroom. Host has 32GB so this is safe.

Builders line: `4 4 - - trusted` - first `4` is max parallel nix builds, second `4` is cores per build (`NIX_BUILD_CORES`). Must match `-smp` or nix will schedule more parallel jobs than the VM has CPUs.

## Tasks

```
task nix-builder-restart   # Restart the VM
task nix-builder-force     # Nuke disk + restart (loses build cache)
```

## Verifying the VM

```
ssh builder@linux-builder uname -a                                         # aarch64 Linux
ssh builder@linux-builder free -h                                          # verify RAM
ssh builder@linux-builder df -h /                                          # verify disk space
ssh builder@linux-builder curl -s https://cache.nixos.org/nix-cache-info  # verify TLS + network
ssh builder@linux-builder sudo -n true && echo "passwordless sudo works"  # verify sudo
```

## Known issues

### Do NOT set extra-platforms = aarch64-linux

This tells nix "build aarch64-linux right here on this Mac". Nix then tries to run Linux ELF binaries on macOS and fails with `Undefined error: 0`. Remove it.

The `builders` line alone is sufficient to route aarch64-linux builds to the VM:
```
builders = ssh-ng://builder@linux-builder aarch64-linux /etc/nix/builder_ed25519 4 4 - - trusted
```

### SSH key permissions (nix-darwin/nix-darwin#913)

After every daemon restart, `/etc/nix/builder_ed25519` is reset to root-owned 600. The key must be `chmod 644` for regular user SSH (used by `nix-pi-*` tasks which run as the user).

Note: `chmod 644` makes SSH reject the key as "too open" when used with sudo. For `task nix-max` (which uses sudo), run `sudo chmod 600 /etc/nix/builder_ed25519` first, then restore to 644 after.

### /var/lib/linux-builder must exist before the daemon starts

launchd fails if the working directory doesn't exist. The activation script creates it, but if it races, the daemon starts in `/` and QEMU fails with "Read-only file system".

Fix: `sudo mkdir -p /var/lib/linux-builder`

### /etc/nix/nix.custom.conf conflicts on first apply

Determinate Nix creates `/etc/nix/nix.custom.conf` before nix-darwin manages it. nix-darwin refuses to overwrite it.

Fix (one-time, before first `task nix-max`):
```
sudo mv /etc/nix/nix.custom.conf /etc/nix/nix.custom.conf.before-nix-darwin
```

### NIX_SSL_CERT_FILE must be set in launchd EnvironmentVariables

`run-nixos-vm` copies `$NIX_SSL_CERT_FILE` into the VM as the CA bundle. If unset, the VM boots with no trusted certs and all TLS fetches (cache.nixos.org, cachix) fail silently.

### Disk full during large builds

MongoDB + dependencies exceed 40GB during compilation. Every source build attempt failed with a full disk. Do not attempt to build MongoDB from source - use the pre-built Raspberry Pi binaries from themattman/mongodb-raspberrypi-binaries instead (see `modules/nixos/unifi-prebuilt.nix`).

`virtualisation.diskSize` needs `lib.mkForce` because the builder profile hardcodes 20480. The override must use a module function to get `lib` in scope:

```nix
builder = pkgs.darwin.linux-builder.override {
  modules = [
    ({ lib, ... }: {
      virtualisation.diskSize = lib.mkForce 30720;
    })
  ];
};
```

To resize the qcow2 without losing the Nix store cache:
```
# Stop the VM
sudo launchctl stop system/org.nixos.linux-builder && sudo pkill -f qemu-system-aarch64

# Resize the image (absolute size, not relative)
sudo /nix/store/<qemu-pkg>/bin/qemu-img resize /var/lib/linux-builder/nixos.qcow2 40G

# Start the VM
sudo launchctl kickstart -k system/org.nixos.linux-builder

# Expand the filesystem inside the VM (requires passwordless sudo)
ssh builder@linux-builder sudo resize2fs /dev/vda
```

Verify with:
```
ssh builder@linux-builder sudo blockdev --getsize64 /dev/vda  # should be 42949672960 (40GB)
ssh builder@linux-builder df -h /
```

Note: `qemu-img resize 40G` sets absolute size. `qemu-img info` shows virtual size. The file size on disk is smaller because qcow2 is sparse.

### VM override is a chicken-and-egg problem

Any override to `pkgs.darwin.linux-builder` requires building a custom NixOS image for aarch64-linux. This needs a working Linux builder. Solution: the running builder handles it, but `extra-platforms` must be absent and the SSH key must be 600 when running `task nix-max`.

### Passwordless sudo requires wheel group membership

`security.sudo.wheelNeedsPassword = false` only affects the wheel group. The builder user is not in wheel by default. Must add both:

```nix
security.sudo.wheelNeedsPassword = false;
users.users.builder.extraGroups = [ "wheel" ];
```

### OOM during MongoDB compilation

MongoDB 7.0 is template-heavy C++. Each parallel g++ job can use 3-4GB. Default VM (3GB RAM, 1 core) is nowhere near enough. Current settings (4 cores, 16GB) give ~4GB/job.

MongoDB 7.0 + Boost 1.79 also fail to compile with GCC 15 (nixpkgs default). Override with GCC 13:

```nix
mongodb-7_0 = pkgs'.mongodb-7_0.override {
  stdenv = pkgs'.gcc13Stdenv;
  boost = pkgs'.boost179.override { stdenv = pkgs'.gcc13Stdenv; };
};
```

### Old or corrupted qcow2 after killed QEMU

If QEMU is killed mid-write the image can corrupt. Symptom: VM boots but SSH hangs at banner exchange.

Fix: `task nix-builder-force` (deletes image, loses build cache)
