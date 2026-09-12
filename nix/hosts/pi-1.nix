{ config, ... }:
let
  secrets = (import ../secrets.nix).read ../../secretspec.toml;
in
{
  # Networking
  networking.hostName = "pi-1";

  # Pin hostnames to static IPs to bypass unreliable Avahi DNS on UNAS.
  networking.hosts.${config.my.nas.ip} = [ config.my.nas.hostName ];

  # Tailscale
  services.onepassword-secrets.secrets.tailscaleAuthKey = {
    reference = secrets.ref "TAILSCALE_AUTHKEY_PI_1";
    owner = "root";
    mode = "0600";
  };

  # AdGuard
  # Bind only on LAN and tailscale — keeps resolved's stub (127.0.0.53:53)
  # intact so the pi's own DNS goes through resolved, not AdGuard.
  services.adguard-home.bindHosts = [
    config.my.host."pi-1".lanIp
    config.my.host."pi-1".tailscaleIp
  ];

  services.onepassword-secrets.secrets.adguardUsername = {
    reference = secrets.ref "ADGUARD_USERNAME";
    owner = "root";
    mode = "0600";
  };

  services.onepassword-secrets.secrets.adguardPasswordHash = {
    reference = secrets.ref "ADGUARD_PASSWORD_HASH";
    owner = "root";
    mode = "0600";
  };

  # Beszel
  services.onepassword-secrets.secrets.beszelAgentKey = {
    reference = secrets.ref "BESZEL_AGENT_PUBLIC_KEY";
    owner = "beszel-agent";
    mode = "0600";
  };

  services.onepassword-secrets.secrets.beszelHubAdmin = {
    reference = secrets.ref "BESZEL_HUB_ADMIN";
    owner = "beszel-hub";
    mode = "0600";
  };

  services.onepassword-secrets.secrets.beszelHubKey = {
    reference = secrets.ref "BESZEL_HUB_PRIVATE_KEY";
    path = "/var/lib/beszel-hub/beszel_data/id_ed25519";
    owner = "beszel-hub";
    mode = "0600";
  };

  # Fusion
  services.onepassword-secrets.secrets.fusionPassword = {
    reference = secrets.ref "FUSION_PASSWORD";
    owner = "fusion";
    mode = "0600";
  };

  # Traefik
  services.onepassword-secrets.secrets.cloudflareDnsToken = {
    reference = secrets.ref "CLOUDFLARE_DNS_CHALLENGE_TOKEN";
    owner = "root";
    mode = "0600";
  };

  # Glance
  services.onepassword-secrets.secrets.waqiToken = {
    reference = secrets.ref "WAQI_API_TOKEN";
    owner = "root";
    mode = "0600";
  };

  # NAS
  # SMB credentials for CIFS mount (username=, password=, domain= file format)
  services.onepassword-secrets.secrets.unasCredentials = {
    reference = secrets.ref "UNAS_SMB_CREDENTIALS";
    owner = "root";
    mode = "0600";
  };

  # Backups
  # Restic repository encryption password
  services.onepassword-secrets.secrets.resticPassword = {
    reference = secrets.ref "RESTIC_REPOSITORY_PASSWORD";
    owner = "root";
    mode = "0600";
  };

  # Cloudflare R2 credentials for the offsite copy. Two fields rather than one env
  # file: opnix maps one reference to one file, and restic-offsite exports them itself.
  services.onepassword-secrets.secrets.resticR2KeyId = {
    reference = secrets.ref "CLOUDFLARE_R2_ACCESS_KEY_ID";
    owner = "root";
    mode = "0600";
  };

  services.onepassword-secrets.secrets.resticR2Secret = {
    reference = secrets.ref "CLOUDFLARE_R2_SECRET_ACCESS_KEY";
    owner = "root";
    mode = "0600";
  };

  # ntfy topic URL — treated as a secret since the topic name is the only access control
  services.onepassword-secrets.secrets.ntfyUrl = {
    reference = secrets.ref "NTFY_HOMELAB_BACKUPS_URL";
    owner = "root";
    mode = "0600";
  };

  # Stagger to avoid overlapping runs. All jobs share one repo, and `forget --prune`
  # takes an exclusive lock — two prunes at once means the second fails rather than
  # waits, since restic does not retry locks by default. Jobs finish in 10-60s, so
  # 5-minute gaps leave ample headroom.
  #
  # One hour per host: pi-1 owns 01:xx, pi-2 owns 02:xx, pi-3 owns 03:xx. The hour
  # is the collision guard, so a host can add jobs without checking the others.
  services.restic-beszel.backupSchedule = "*-*-* 01:00:00";
  services.restic-adguard.backupSchedule = "*-*-* 01:05:00";
  services.restic-fusion.backupSchedule = "*-*-* 01:10:00";
  services.restic-gatus.backupSchedule = "*-*-* 01:15:00";

  # Runs after every host's hour, so one pass carries the whole night to R2.
  services.restic-offsite.schedule = "*-*-* 04:00:00";

  # Prometheus on pi-2 scrapes this over the tailnet. The default 127.0.0.1 suits
  # hosts whose dashboard Traefik proxies locally, which pi-1 is — but that also
  # made it the one kula endpoint pi-2 could not reach.
  services.kula.listenAddress = "0.0.0.0";

  services.backup-healthcheck.checks = {
    # port 8099: localhost-only HTTP shim for beszel backup freshness.
    beszel = {
      port = 8099;
    };
    # port 8100: localhost-only HTTP shim for adguard backup freshness.
    adguard = {
      port = 8100;
    };
  };

  services.backup-healthcheck.checks.fusion = {
    port = 8102;
  };

  # port 8104: localhost-only HTTP shim for gatus backup freshness.
  services.backup-healthcheck.checks.gatus = {
    port = 8104;
  };

  # port 8103: offsite copy to R2. maxAge is the default 25h — the copy runs daily
  # at 04:00, after the last host's hour.
  services.backup-healthcheck.checks.offsite = {
    port = 8103;
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
}
