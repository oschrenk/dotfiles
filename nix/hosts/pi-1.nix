let
  # Host network addresses. Referenced by any service that needs to bind or
  # connect to a specific interface. Update here if IPs change.
  lanIp       = "192.168.1.7";
  tailscaleIp = "100.125.174.68";
in
{
  networking.hostName = "pi-1";

  # Pin hostnames to static IPs to bypass unreliable Avahi DNS on UNAS.
  # Update and redeploy if IPs change.
  networking.hosts = {
    "192.168.1.241" = [ "unas.local" ];
  };

  services.onepassword-secrets.secrets.tailscaleAuthKey = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/2imqxgbvx6htswijyuswh72kye/pi-1";
    owner = "root";
    mode = "0600";
  };

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

  # SMB credentials for CIFS mount (username=, password=, domain= file format)
  services.onepassword-secrets.secrets.unasCredentials = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/nlu6b76afi6kmgrjovrlw7bnrq/smb credentials";
    owner = "root";
    mode = "0600";
  };

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

  services.onepassword-secrets.secrets.adguardUsername = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/x2e3npasfpczengdmzxxglby2a/username";
    owner     = "root";
    mode      = "0600";
  };

  services.onepassword-secrets.secrets.adguardPasswordHash = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/x2e3npasfpczengdmzxxglby2a/bcrypt password";
    owner     = "root";
    mode      = "0600";
  };

  # Bind only on LAN and tailscale — keeps resolved's stub (127.0.0.53:53)
  # intact so the pi's own DNS goes through resolved, not AdGuard.
  services.adguard-home.bindHosts = [ lanIp tailscaleIp ];

  services.homelab-proxy.domain  = "pi-1.local";
  services.homelab-proxy.localIp = tailscaleIp;

  # step-ca — see nix/modules/nixos/step-ca.nix for bootstrap instructions.
  # Prerequisites before deploying:
  #   1. Bootstrap has been run on the Pi (step ca init + provisioner add acme)
  #   2. ca.json content is stored in 1Password (opnix reference below)
  #   3. Intermediate key password is stored in 1Password (opnix reference below)
  # Ownership of .step/ is fixed automatically by systemd-tmpfiles on every boot.
  services.onepassword-secrets.secrets.stepCaConfig = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/zf43l4tp5emchhsa75o5i46b5u/ql6hn7chrecivmrns4wextxvfe";
    path      = "/run/step-ca.json";
    owner     = "step-ca";
    mode      = "0600";
  };

  # step-ca intermediate key password — written to tmpfs on boot, never on persistent disk
  services.onepassword-secrets.secrets.stepCaPassword = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/zf43l4tp5emchhsa75o5i46b5u/password";
    path      = "/run/step-ca-password";
    owner     = "root";
    mode      = "0600";
  };

  # DNS rewrites: Tailscale clients resolve *.pi-1.local via AdGuard.
  # mDNS (.local) does not work over Tailscale — AdGuard must answer these.
  #
  # Why user_rules instead of dns.rewrites:
  #   AdGuard Home treats .local as mDNS-reserved (RFC 6762) and silently strips
  #   any entries in dns.rewrites that match *.local during startup normalisation.
  #   The store YAML has the rewrites, but /var/lib/AdGuardHome/AdGuardHome.yaml
  #   ends up with rewrites: [] after AdGuard processes the file.
  #   user_rules with the $dnsrewrite modifier bypass this normalisation entirely.
  #
  # Wildcard pattern: ||pi-1.local^ matches pi-1.local and every subdomain.
  services.adguardhome.settings.user_rules = [
    "||pi-1.local^$dnsrewrite=NOERROR;A;${tailscaleIp}"
  ];

  services.backup-healthcheck.checks = {
    # port 8099: localhost-only HTTP shim for beszel backup freshness.
    beszel  = { port = 8099; };
    # port 8100: localhost-only HTTP shim for adguard backup freshness.
    adguard = { port = 8100; };
  };

  # Stagger to avoid concurrent NAS access (both default to "daily" = midnight).
  # 30min gap is enough for either backup to finish before the other starts.
  services.restic-beszel.backupSchedule   = "*-*-* 01:00:00";
  services.restic-adguard.backupSchedule  = "*-*-* 01:30:00";
  services.restic-step-ca.backupSchedule  = "*-*-* 02:00:00";

  services.backup-healthcheck.checks.step-ca = { port = 8101; };

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
