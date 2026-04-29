# aarch64-linux builder VM for cross-compiling packages that nixpkgs won't cache
# (SSPL-licensed packages like MongoDB are skipped by Hydra).
# Runs a QEMU/HVF NixOS VM on macOS via launchd, accessible as ssh builder@linux-builder.
# See nix/docs/builder.md for setup, maintenance, and known issues.
{ pkgs, lib, ... }:
let
  builder = pkgs.darwin.linux-builder.override {
    modules = [
      ({ ... }: {
        # Allow passwordless sudo for maintenance commands.
        security.sudo.wheelNeedsPassword = false;
        # Add builder to wheel so wheelNeedsPassword = false applies.
        users.users.builder.extraGroups = [ "wheel" ];
      })
    ];
  };
in
{
  # Create the working directory for the linux-builder VM before the daemon
  # starts. postActivation is the last hardcoded activation hook in nix-darwin
  # and reliably runs before launchd daemons are (re)loaded.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    mkdir -p /var/lib/linux-builder
  '';

  # Run the linux-builder VM as a persistent launchd daemon.
  # Uses macOS Virtualization framework; starts automatically on boot.
  launchd.daemons.linux-builder = {
    serviceConfig = {
      ProgramArguments = [ "${builder}/bin/create-builder" ];
      KeepAlive = true;
      RunAtLoad = true;
      WorkingDirectory = "/var/lib/linux-builder";
      EnvironmentVariables = {
        # run-nixos-vm copies this file into the VM as the CA bundle.
        # Without it the VM has no trusted certs and TLS fetches fail.
        NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
        # Give the VM more CPUs and RAM for parallel builds.
        # run-nixos-vm hardcodes -m 3072 and -smp 1; QEMU_OPTS is appended last
        # so these values win (QEMU uses the last occurrence of each flag).
        QEMU_OPTS = "-smp 4 -m 8192";
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

  # Register the VM as a remote builder and preserve existing Determinate
  # Nix custom settings (extra-platforms, cachix, trusted-users).
  # Determinate does not overwrite nix.custom.conf so it is safe to manage here.
  environment.etc."nix/nix.custom.conf".text = ''
    trusted-users = oliver

    extra-substituters = https://nixos-raspberrypi.cachix.org
    extra-trusted-public-keys = nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI=

    builders-use-substitutes = true
    builders = ssh-ng://builder@linux-builder aarch64-linux /etc/nix/builder_ed25519 4 4 - - trusted
  '';
}
