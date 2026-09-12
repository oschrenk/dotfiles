{ config, ... }:
let
  secrets = (import ../secrets.nix).read ../../secretspec.toml;
in
{
  # Networking
  networking.hostName = "pi-2";

  # Pin hostnames to static IPs to bypass unreliable Avahi DNS on UNAS.
  networking.hosts.${config.my.nas.ip} = [ config.my.nas.hostName ];

  # Tailscale
  services.onepassword-secrets.secrets.tailscaleAuthKey = {
    reference = secrets.ref "TAILSCALE_AUTHKEY_PI_2";
    owner = "root";
    mode = "0600";
  };

  # Beszel
  services.onepassword-secrets.secrets.beszelAgentKey = {
    reference = secrets.ref "BESZEL_AGENT_PUBLIC_KEY";
    owner = "beszel-agent";
    mode = "0600";
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

  # Backups
  # SMB credentials for the UNAS CIFS mount (username=, password=, domain= format)
  services.onepassword-secrets.secrets.unasCredentials = {
    reference = secrets.ref "UNAS_SMB_CREDENTIALS";
    owner = "root";
    mode = "0600";
  };

  # Same repository password as pi-1: one shared repo, one secret to lose.
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

  # pi-2 owns the 02:xx hour in the shared repo. Add jobs at 02:05, 02:10 and so
  # on; the hour keeps them clear of pi-1 and pi-3 without any cross-host check.
  services.restic-prometheus.backupSchedule = "*-*-* 02:00:00";

  # Nothing polls this yet — Gatus runs on pi-1 and the healthcheck socket binds
  # localhost. The stamp file is written regardless, and ntfy is the actual
  # notification path.
  services.backup-healthcheck.checks.prometheus = {
    port = 8099;
  };

  # unpoller
  # Owned by the unpoller service user, not root: inputunifi opens the file itself
  # via its file:// reference, and the ExecStart wrapper reads the UNAS one as the
  # same user.
  services.onepassword-secrets.secrets.unpollerUnasPassword = {
    reference = secrets.ref "UNAS_ACCOUNT_PASSWORD";
    owner = "unpoller";
    mode = "0400";
  };

  services.onepassword-secrets.secrets.unpollerUnifiPassword = {
    reference = secrets.ref "UNIFI_ADMIN_PASSWORD";
    owner = "unpoller";
    mode = "0400";
  };

  # Perses
  services.onepassword-secrets.secrets.persesEncryptionKey = {
    reference = secrets.ref "PERSES_ENCRYPTION_KEY";
    owner = "root";
    mode = "0600";
  };

  services.onepassword-secrets.secrets.persesAdminPassword = {
    reference = secrets.ref "PERSES_ADMIN_PASSWORD";
    owner = "root";
    mode = "0600";
  };
}
