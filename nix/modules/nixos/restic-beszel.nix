{ config, pkgs, lib, ... }:
let
  cfg = config.services.restic-beszel;
in
{
  options.services.restic-beszel.backupSchedule = lib.mkOption {
    type        = lib.types.str;
    default     = "daily";
    description = "OnCalendar value for the restic timer. Override per-host without touching this module.";
  };

  config = {
  # CIFS mount for the Unifi UNAS Personal-Drive share (per-user share for homelab-backup).
  # Note: the UNAS also exposes a global "Backups" share, but that is not per-user.
  # Personal-Drive is the correct target for isolated, per-user backup storage.
  #
  # credentials file format (stored as text field 'smb credentials' in 1Password, dropped by opnix):
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
  fileSystems."/mnt/unas_backup" = {
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

  # Testing (run on pi-1):
  #
  #   Success:
  #     sudo systemctl start restic-backups-beszel.service
  #     sudo restic -r /mnt/unas_backup/restic-pi1 --password-file /var/lib/opnix/secrets/resticPassword snapshots
  #
  #   Failure (simulates NAS unreachable — takes ~30s for mount timeout):
  #     sudo iptables -A OUTPUT -d 192.168.1.241 -j DROP && sudo umount /mnt/unas_backup
  #     sudo systemctl start restic-backups-beszel.service
  #     sudo iptables -D OUTPUT -d 192.168.1.241 -j DROP
  #     WARNING: -A stacks rules; -D only removes one copy. Run multiple times if needed.
  #     Verify clean: sudo iptables -L OUTPUT -n  (should show no DROP for 192.168.1.241)

  # cifs kernel module must be explicitly loaded on NixOS — cifs-utils alone is not enough.
  boot.kernelModules = [ "cifs" ];
  environment.systemPackages = [
    pkgs.cifs-utils
    # restic for interactive use: manual backups and snapshot inspection, e.g.:
    # sudo restic -r /mnt/unas_backup/restic-pi1 --password-file /var/lib/opnix/secrets/resticPassword snapshots
    pkgs.restic
  ];

  services.restic.backups.beszel = {
    paths = [ "${config.services.beszel.hub.dataDir}/beszel_data" ];
    repository = "/mnt/unas_backup/restic-pi1";
    passwordFile = "/var/lib/opnix/secrets/resticPassword";

    timerConfig = {
      OnCalendar = cfg.backupSchedule;
      Persistent = true; # run missed backups after downtime
    };

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
    ];

    # beszel-hub is NOT stopped before backup. PocketBase uses WAL mode which makes
    # online backups safe — a consistent snapshot is guaranteed by SQLite's WAL.
    # The data (uptime graphs) is low-value enough that a missed second is acceptable.
    backupPrepareCommand = ''
      date +%s > /tmp/restic-beszel-start
    '';

    # backupCleanupCommand maps to ExecStopPost — runs on success or failure of the
    # service itself, but NOT when the service fails to start due to a dependency
    # (e.g. RequiresMountsFor). Failure notifications for dependency failures are
    # handled by the OnFailure= unit below.
    #
    # Stats are parsed from the journal using the recorded start time so we only
    # look at the current run (not previous runs). The "processed N files," line
    # comes from the backup step; prune also emits "processed" lines which would
    # match a naive grep — using --since "@$START" avoids that ambiguity.
    backupCleanupCommand = ''
      if [ "$SERVICE_RESULT" = "success" ]; then
        NTFY_URL="$(cat /var/lib/opnix/secrets/ntfyUrl)"
        START="$(cat /tmp/restic-beszel-start 2>/dev/null || echo 0)"
        NOW="$(date +%s)"
        DURATION="$((NOW - START))s"
        STATS="$(${pkgs.systemd}/bin/journalctl -u restic-backups-beszel.service --since "@$START" --no-pager --output=cat 2>/dev/null | grep "processed [0-9]* files," | tail -1 | sed 's/processed \([0-9]*\) files, \([0-9]*\)\.[0-9]* \([A-Za-z]*\) in [0-9]*:[0-9]*/\1 files (\2 \3)/')"
        ${pkgs.curl}/bin/curl -s -o /dev/null \
          -H "Title: Homelab / Backup / Beszel" \
          -H "Tags: white_check_mark" \
          -d "$STATS in $DURATION" \
          "$NTFY_URL"
        touch ${config.services.backup-healthcheck.statusDir}/beszel || true
      fi
    '';

    initialize = true; # runs `restic init` on first start if repo is empty
  };

  # RequiresMountsFor ensures the service fails immediately if the CIFS mount is
  # not available. Without this, restic's initialize=true would create a new local
  # repo on the bare mount point directory and back up to the Pi's SD card instead
  # of the NAS — appearing to succeed while writing nothing to the NAS.
  #
  # OnFailure= handles failure notifications for ALL failure modes, including
  # dependency failures (e.g. NAS unreachable) where ExecStopPost never runs.
  systemd.services.restic-backups-beszel = {
    unitConfig = {
      RequiresMountsFor = "/mnt/unas_backup";
      OnFailure = "restic-backups-beszel-notify-failure.service";
    };
  };

  # Sends failure ntfy notification. Triggered via OnFailure= so it fires even
  # when the backup service fails to start (e.g. NAS mount unavailable).
  systemd.services.restic-backups-beszel-notify-failure = {
    description = "Notify on restic-backups-beszel failure";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "restic-beszel-notify-failure" ''
        NTFY_URL="$(cat /var/lib/opnix/secrets/ntfyUrl)"
        ${pkgs.curl}/bin/curl -s -o /dev/null \
          -H "Title: Homelab / Backup / Beszel" \
          -H "Tags: x" \
          -H "Priority: high" \
          -d "Backup FAILED — check journalctl -u restic-backups-beszel" \
          "$NTFY_URL"
      '';
    };
  };
  };
}
