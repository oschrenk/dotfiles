{ config, ... }:
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
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/pr3tmmcv6crtd36wqyqh3vdnmu/Public Key";
    owner = "beszel-agent";
    mode = "0600";
  };

  # Backups
  # Same three 1Password items pi-1 and pi-2 use: one shared repo on the UNAS, one
  # password, one ntfy topic.
  services.onepassword-secrets.secrets.unasCredentials = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/nlu6b76afi6kmgrjovrlw7bnrq/smb credentials";
    owner = "root";
    mode = "0600";
  };

  services.onepassword-secrets.secrets.resticPassword = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/mvunkul72kvdmvdkbycvsg7ogq/password";
    owner = "root";
    mode = "0600";
  };

  services.onepassword-secrets.secrets.ntfyUrl = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/5gsl762zsgopnb7noenx44teey/homelab-backups";
    owner = "root";
    mode = "0600";
  };

  # Last local job of the night, ahead of pi-1's offsite copy at 01:25, so the
  # night's controller backup reaches R2 on the same run.
  services.restic-unifi.backupSchedule = "*-*-* 01:20:00";

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
