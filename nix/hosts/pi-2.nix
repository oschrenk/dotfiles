{ config, ... }:
{
  # Networking
  networking.hostName = "pi-2";

  # Pin hostnames to static IPs to bypass unreliable Avahi DNS on UNAS.
  networking.hosts.${config.my.nas.ip} = [ config.my.nas.hostName ];

  # Tailscale
  services.onepassword-secrets.secrets.tailscaleAuthKey = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/2imqxgbvx6htswijyuswh72kye/pi-2";
    owner = "root";
    mode = "0600";
  };

  # Beszel
  services.onepassword-secrets.secrets.beszelAgentKey = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/pr3tmmcv6crtd36wqyqh3vdnmu/Public Key";
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
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/nlu6b76afi6kmgrjovrlw7bnrq/smb credentials";
    owner = "root";
    mode = "0600";
  };

  # Same repository password as pi-1: one shared repo, one secret to lose.
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

  # Slots between pi-1's last local job (01:10) and the offsite copy (01:20), so
  # the night's snapshot reaches R2 the same run.
  services.restic-prometheus.backupSchedule = "*-*-* 01:15:00";

  # Nothing polls this yet — Gatus runs on pi-1 and the healthcheck socket binds
  # localhost. DOTFILES-05 section 5 makes it cross-host; until then the stamp file
  # is written and ntfy is the actual notification path.
  services.backup-healthcheck.checks.prometheus = {
    port = 8099;
  };

  # Perses
  services.onepassword-secrets.secrets.persesEncryptionKey = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/nnur4ctpce2l3dfoqettgcr3ay/encryption key";
    owner = "root";
    mode = "0600";
  };

  services.onepassword-secrets.secrets.persesAdminPassword = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/nnur4ctpce2l3dfoqettgcr3ay/password";
    owner = "root";
    mode = "0600";
  };
}
