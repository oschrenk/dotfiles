{ config, ... }:
{
  # Host network addresses. Update here if IPs change.
  my.host."pi-1" = {
    lanIp = "192.168.1.7";
    tailscaleIp = "100.125.174.68";
    mac = "dc:a6:32:6b:00:e8";
  };

  my.domain.homelab = {
    name = "home.lan";
    hostName = "pi-1";
  };

  # Networking
  networking.hostName = "pi-1";

  # Pin hostnames to static IPs to bypass unreliable Avahi DNS on UNAS.
  # Update and redeploy if IPs change.
  networking.hosts = {
    "192.168.1.241" = [ "unas.local" ];
  };

  # Tailscale
  services.onepassword-secrets.secrets.tailscaleAuthKey = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/2imqxgbvx6htswijyuswh72kye/pi-1";
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
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/x2e3npasfpczengdmzxxglby2a/username";
    owner = "root";
    mode = "0600";
  };

  services.onepassword-secrets.secrets.adguardPasswordHash = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/x2e3npasfpczengdmzxxglby2a/bcrypt password";
    owner = "root";
    mode = "0600";
  };

  # Beszel
  services.onepassword-secrets.secrets.beszelAgentKey = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/pr3tmmcv6crtd36wqyqh3vdnmu/Public Key";
    owner = "beszel-agent";
    mode = "0600";
  };

  services.onepassword-secrets.secrets.beszelHubAdmin = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/pr3tmmcv6crtd36wqyqh3vdnmu/notesPlain";
    owner = "beszel-hub";
    mode = "0600";
  };

  services.onepassword-secrets.secrets.beszelHubKey = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/pr3tmmcv6crtd36wqyqh3vdnmu/Private Key";
    path = "/var/lib/beszel-hub/beszel_data/id_ed25519";
    owner = "beszel-hub";
    mode = "0600";
  };

  # NAS
  # SMB credentials for CIFS mount (username=, password=, domain= file format)
  services.onepassword-secrets.secrets.unasCredentials = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/nlu6b76afi6kmgrjovrlw7bnrq/smb credentials";
    owner = "root";
    mode = "0600";
  };

  # step-ca
  # Root CA cert — traefik's lego client trusts it via LEGO_CA_CERTIFICATES (homelab.nix).
  services.onepassword-secrets.secrets.stepCaConfig = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/zf43l4tp5emchhsa75o5i46b5u/ql6hn7chrecivmrns4wextxvfe";
    path = "/run/step-ca.json";
    owner = "step-ca";
    mode = "0600";
  };

  services.onepassword-secrets.secrets.stepCaPassword = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/zf43l4tp5emchhsa75o5i46b5u/password";
    path = "/run/step-ca-password";
    owner = "root";
    mode = "0600";
  };

  services.onepassword-secrets.secrets.stepCaRootCert = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/zf43l4tp5emchhsa75o5i46b5u/pu4k27p33n2a5g4mlwztdzzmeq";
    path = "/run/step-ca-root.crt";
    owner = "root";
    mode = "0644";
  };

  # Backups
  # Restic repository encryption password
  services.onepassword-secrets.secrets.resticPassword = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/mvunkul72kvdmvdkbycvsg7ogq/password";
    owner = "root";
    mode = "0600";
  };

  # ntfy topic URL — treated as a secret since the topic name is the only access control
  services.onepassword-secrets.secrets.ntfyUrl = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/5gsl762zsgopnb7noenx44teey/homelab-backups";
    owner = "root";
    mode = "0600";
  };

  # Stagger to avoid concurrent NAS access. Backups complete in 10-30s so
  # 15-minute intervals are sufficient; this also leaves 01:45 free for pi-3.
  services.restic-beszel.backupSchedule = "*-*-* 01:00:00";
  services.restic-adguard.backupSchedule = "*-*-* 01:15:00";
  services.restic-step-ca.backupSchedule = "*-*-* 01:30:00";

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

  services.backup-healthcheck.checks.step-ca = {
    port = 8101;
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
