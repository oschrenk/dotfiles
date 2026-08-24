# aarch64-linux builder VM for cross-compiling packages that nixpkgs won't cache
# (SSPL-licensed packages like MongoDB are skipped by Hydra).
# Runs a QEMU/HVF NixOS VM on macOS via launchd, accessible as ssh builder@linux-builder.
# See docs/nix/builder.md for setup, maintenance, and known issues.
{ pkgs, lib, ... }:
let
  # qemu unpinned: using nixpkgs qemu (11.0.1+). Previously pinned to 10.2.2
  # because 11.0.0 asserted in HVF on macOS 26 (Tahoe) at sysreg.c.inc:149
  # (HV_SYS_REG_SMCR_EL1 mismatch, incomplete FEAT_SME2 register handling).
  # If the builder VM fails to boot with that assertion, restore the pin.
  # See docs/nix/builder.md.
  builder = pkgs.darwin.linux-builder;
in
{
  # Create the working directory for the linux-builder VM before the daemon
  # starts. postActivation is the last hardcoded activation hook in nix-darwin
  # and reliably runs before launchd daemons are (re)loaded.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    mkdir -p /var/lib/linux-builder
  '';

  # Run the linux-builder VM as an on-demand launchd daemon. It is needed a few
  # times a day for pi rebuilds, and idles the rest of the time holding its full
  # memory allocation — which on a 16 GB machine lands in swap and slows
  # everything down. The rebuild tasks in taskfile.yml kickstart it and wait for
  # the port, so it starts when it is actually wanted.
  launchd.daemons.linux-builder = {
    serviceConfig = {
      ProgramArguments = [ "${builder}/bin/create-builder" ];
      KeepAlive = false;
      RunAtLoad = false;
      WorkingDirectory = "/var/lib/linux-builder";
      EnvironmentVariables = {
        # run-nixos-vm copies this file into the VM as the CA bundle.
        # Without it the VM has no trusted certs and TLS fetches fail.
        NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
        # Give the VM more CPUs for parallel builds. RAM stays at run-nixos-vm's
        # own 3072: the builds this runs are pi closures, which never came close
        # to 6 GB, and the VM holds that reservation the whole time it is up.
        # run-nixos-vm hardcodes -m 3072 and -smp 1; QEMU_OPTS is appended last
        # so these values win (QEMU uses the last occurrence of each flag). -m is
        # restated rather than dropped so the VM's size is visible here.
        #
        # -machine overrides run-nixos-vm's hardcoded `virt,gic-version=2,accel=hvf:tcg`.
        # HVF cannot emulate GICv2 — Apple's hypervisor exposes GICv3 only. qemu 11.1.0
        # rejects the combination outright ("HVF does not support GICv2 emulation")
        # instead of falling back to TCG, so the VM fails to start at all.
        QEMU_OPTS = "-smp 4 -m 3072 -machine virt,gic-version=3,accel=hvf:tcg";
      };
      StandardOutPath = "/var/log/linux-builder.log";
      StandardErrorPath = "/var/log/linux-builder.log";
      ThrottleInterval = 30;
    };
  };

  # SSH config so `linux-builder` hostname resolves to the VM's port.
  environment.etc."ssh/ssh_config.d/100-linux-builder.conf".text = ''
    Host linux-builder
      Hostname localhost
      HostKeyAlias linux-builder
      Port 31022
      User builder
      IdentityFile /etc/nix/builder_ed25519
      StrictHostKeyChecking no
      ConnectionAttempts 8
      ConnectTimeout 120
  '';

  # Register the VM as a remote builder. General nix settings (trusted-users,
  # caches) live in nix.nix; only the builder registration lives here.
  # This drop-in merges with nix.nix's; Determinate does not overwrite it.
  environment.etc."nix/nix.custom.conf".text = ''
    builders-use-substitutes = true
    builders = ssh-ng://builder@linux-builder aarch64-linux /etc/nix/builder_ed25519 4 4 - - trusted
  '';
}
