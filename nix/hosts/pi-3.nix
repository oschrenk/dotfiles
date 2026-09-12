{ config, ... }:
let
  secrets = (import ../secrets.nix).read ../../secretspec.toml;
in
{
  # Networking
  networking.hostName = "pi-3";

  # Pin hostnames to static IPs to bypass unreliable Avahi DNS on UNAS.
  networking.hosts.${config.my.nas.ip} = [ config.my.nas.hostName ];

  # Tailscale
  services.onepassword-secrets.secrets.tailscaleAuthKey = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/2imqxgbvx6htswijyuswh72kye/pi-3";
    owner = "root";
    mode = "0600";
  };

  # Beszel
  services.onepassword-secrets.secrets.beszelAgentKey = {
    reference = secrets.ref "BESZEL_AGENT_PUBLIC_KEY";
    owner = "beszel-agent";
    mode = "0600";
  };

  # Backups
  # Same three 1Password items pi-1 and pi-2 use: one shared repo on the UNAS, one
  # password, one ntfy topic.
  services.onepassword-secrets.secrets.unasCredentials = {
    reference = secrets.ref "UNAS_SMB_CREDENTIALS";
    owner = "root";
    mode = "0600";
  };

  services.onepassword-secrets.secrets.resticPassword = {
    reference = secrets.ref "RESTIC_REPOSITORY_PASSWORD";
    owner = "root";
    mode = "0600";
  };

  services.onepassword-secrets.secrets.ntfyUrl = {
    reference = secrets.ref "NTFY_HOMELAB_BACKUPS_URL";
    owner = "root";
    mode = "0600";
  };

  # pi-3 owns the 03:xx hour in the shared repo. Add jobs at 03:05, 03:10 and so
  # on; the hour keeps them clear of pi-1 and pi-2 without any cross-host check.
  services.restic-unifi.backupSchedule = "*-*-* 03:00:00";

  # port 8099: localhost-only HTTP shim for unifi backup freshness. Same port as
  # pi-2's check — the socket binds 127.0.0.1, so the numbering is per-host.
  services.backup-healthcheck.checks.unifi = {
    port = 8099;
  };

  # Storage
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [
      "noatime" # don't update file access times on reads — reduces writes on flash storage
    ];
  };

  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
    options = [
      "noatime" # don't update access times — reduces writes on flash storage
      "noauto" # don't mount at boot — only needed when updating bootloader/firmware
      "x-systemd.automount" # mount on demand when something accesses /boot/firmware
      "x-systemd.idle-timeout=1min" # unmount after 1 min idle — keeps FAT32 partition safe from corruption
    ];
  };

  # Traefik lives on pi-1, so bind beyond localhost. base.nix opens no LAN ports
  # and trusts tailscale0, so only the tailnet can actually reach it.
  services.kula.listenAddress = "0.0.0.0";
}
