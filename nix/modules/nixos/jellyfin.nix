{ pkgs, lib, nixpkgs-jellyfin, ... }:
let
  # Jellyfin 10.11.x has a critical startup bug on NixOS aarch64: the setup
  # server (wizard) auto-completes and then its StopApplication() bleeds into
  # the main server lifecycle, causing it to exit 5 seconds after Kestrel binds.
  # Pin to 10.10.7 from nixos-24.11 which does not have this bug.
  pkgs-jellyfin = nixpkgs-jellyfin.legacyPackages.${pkgs.system};

  # jellyfin-ffmpeg-bin is a pre-built binary that fails on NixOS aarch64
  # (incompatible dynamic linker). The nixpkgs wrapper hardcodes --ffmpeg= on
  # the command line, which overrides encoding.xml. Patch the wrapper to point
  # at nixpkgs ffmpeg instead. symlinkJoin avoids rebuilding the C# binary.
  jellyfinWithSystemFfmpeg = pkgs.symlinkJoin {
    name = "jellyfin-system-ffmpeg";
    paths = [ pkgs-jellyfin.jellyfin ];
    meta = pkgs-jellyfin.jellyfin.meta // { mainProgram = "jellyfin"; };
    postBuild = ''
      rm $out/bin/jellyfin
      sed 's|--ffmpeg=[^ "]*|--ffmpeg=${pkgs.ffmpeg}/bin/ffmpeg|g' \
        ${pkgs-jellyfin.jellyfin}/bin/jellyfin > $out/bin/jellyfin
      chmod +x $out/bin/jellyfin
    '';
  };
in
{
  services.jellyfin = {
    enable = true;
    openFirewall = true; # opens 8096 (HTTP), 8920 (HTTPS), 1900/7359 UDP (discovery)
    package = jellyfinWithSystemFfmpeg;
  };

  # Authenticated CIFS mount for the NAS media library.
  # noauto + x-systemd.automount: mount triggered on first access, not at boot.
  # Prevents boot stall if UNAS is unreachable.
  # ro: media is read-only; Jellyfin never writes to the library.
  # file_mode=0644 + dir_mode=0755: world-readable so the jellyfin user can read files.
  fileSystems."/mnt/unas_media" = {
    device = "//unas.local/Media";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=30s"
      "credentials=/var/lib/opnix/secrets/unasMediaCredentials"
      "uid=0"
      "gid=0"
      "file_mode=0644"
      "dir_mode=0755"
      "ro"
    ];
  };

  # cifs kernel module must be explicitly loaded on NixOS.
  boot.kernelModules = [ "cifs" ];
  environment.systemPackages = [ pkgs.cifs-utils ];

  # automount units don't support reload. X-StopIfChanged tells
  # switch-to-configuration to stop+restart instead of reload on config changes.
  systemd.units."mnt-unas_media.automount" = {
    overrideStrategy = "asDropin";
    text = ''
      [Unit]
      X-StopIfChanged=true
    '';
  };

  # opnix must have dropped the credentials file before jellyfin starts,
  # otherwise the automount triggered by RequiresMountsFor will fail.
  systemd.services.jellyfin = {
    after = [ "opnix-secrets.service" ];
    requires = [ "opnix-secrets.service" ];
    unitConfig.RequiresMountsFor = "/mnt/unas_media";
    # NixOS jellyfin module sets TimeoutSec=15 which applies to both start and stop.
    # Jellyfin takes ~30s to start and ~20s to stop -- both exceed the 15s default.
    serviceConfig.TimeoutStartSec = "90";
    serviceConfig.TimeoutStopSec = "60";
    # Jellyfin calls StopApplication() (exit 0) to restart itself after:
    # - First-run wizard completion
    # - Plugin updates installed on startup
    # Restart=on-success ensures those restarts happen. systemctl stop still
    # works because systemd cancels pending restarts on explicit stop requests.
    # StartLimitBurst prevents an infinite restart loop if something keeps
    # triggering clean exits.
    serviceConfig.Restart = lib.mkForce "on-success";
    startLimitBurst = 5;
    startLimitIntervalSec = 60;
  };
}
