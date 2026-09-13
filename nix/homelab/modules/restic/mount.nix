{ pkgs, ... }:
{
  # CIFS mount for the Unifi UNAS Personal-Drive share (per-user share for
  # homelab-backup). Shared by every host that backs up, so it lives here rather
  # than inside one service's module.
  #
  # Note: the UNAS also exposes a global "Backups" share, but that is not per-user.
  # Personal-Drive is the correct target for isolated, per-user backup storage.
  #
  # credentials file format (stored as text field 'smb credentials' in 1Password,
  # dropped by opnix):
  #   username=homelab-backup
  #   password=<password>
  #   domain=WORKGROUP  ← required; UNAS runs Samba internally
  #
  # noauto + x-systemd.automount: mount is triggered on first access, not at boot.
  # This prevents boot stalls if the UNAS is unreachable.
  #
  # Mount point uses underscore (_), not dash (-). systemd escapes `-` in path
  # components as `\x2d` in unit names, making it painful to reference the unit
  # via systemctl (e.g. for testing). Underscore requires no escaping.
  fileSystems."/mnt/unas_homelab" = {
    device = "//unas.local/Personal-Drive";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=30s" # fail after 30s if UNAS unreachable
      "credentials=/var/lib/opnix/secrets/unasCredentials"
      "uid=0"
      "gid=0"
      "file_mode=0600"
      "dir_mode=0700"
    ];
  };

  # cifs kernel module must be explicitly loaded on NixOS — cifs-utils alone is
  # not enough.
  boot.kernelModules = [ "cifs" ];

  environment.systemPackages = [
    pkgs.cifs-utils
    # restic for interactive use: manual backups and snapshot inspection, e.g.:
    # sudo restic -r /mnt/unas_homelab/restic --password-file /var/lib/opnix/secrets/resticPassword snapshots
    pkgs.restic
  ];
}
