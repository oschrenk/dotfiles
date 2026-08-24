{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.restic-unifi;
  statusDir = config.services.backup-healthcheck.statusDir;

  # data/backup, not /var/lib/unifi. The .unf files are a self-contained BSON export
  # the controller writes itself, so they are consistent by construction and restore
  # through the UI's import path — 112 KB against 515 MB for data/db, which is almost
  # entirely statistics. A file-by-file copy of Mongo under a running server would be
  # neither consistent nor a supported restore.
  #
  # The controller has no cloud backup: that is a UniFi OS console feature, and this is
  # the standalone Network Application. These snapshots are the only offsite copy.
  #
  # How often a fresh .unf appears is a controller setting (Settings → System →
  # Backups), not a nix one — this job only copies whatever is on disk. Set to daily
  # with 0 days of statistics; raising the retention span is what would make these
  # files large.
  dataDir = "/var/lib/unifi/data/backup";
in
{
  options.services.restic-unifi.backupSchedule = lib.mkOption {
    type = lib.types.str;
    default = "daily";
    description = "OnCalendar value for the restic timer. Override per-host to stagger with other backups.";
  };

  config = {
    services.restic.backups.unifi = {
      paths = [ dataDir ];

      repository = "/mnt/unas_homelab/restic";
      passwordFile = "/var/lib/opnix/secrets/resticPassword";

      timerConfig = {
        OnCalendar = cfg.backupSchedule;
        Persistent = true;
      };

      # Same policy as the pi-1 and pi-2 jobs and the offsite copy — change all
      # together. forget groups by host,paths by default, so pi-3's snapshots are
      # retained independently of the others despite sharing one repository.
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
        "--retry-lock 5m"
      ];

      extraBackupArgs = [ "--retry-lock 5m" ];

      initialize = true;

      backupPrepareCommand = ''
        date +%s > /run/restic-unifi-start
      '';

      backupCleanupCommand = ''
        if [ "$SERVICE_RESULT" = "success" ]; then
          NTFY_URL="$(cat /var/lib/opnix/secrets/ntfyUrl)"
          START="$(cat /run/restic-unifi-start 2>/dev/null || echo 0)"
          NOW="$(date +%s)"
          DURATION="$((NOW - START))s"
          STATS="$(${pkgs.systemd}/bin/journalctl -u restic-backups-unifi.service \
            --since "@$START" --no-pager --output=cat 2>/dev/null \
            | grep "processed [0-9]* files," | tail -1 \
            | sed 's/processed \([0-9]*\) files, \([0-9]*\)\.[0-9]* \([A-Za-z]*\) in [0-9]*:[0-9]*/\1 files (\2 \3)/')"
          ${pkgs.curl}/bin/curl -s -o /dev/null \
            -H "Title: Homelab / Backup / UniFi" \
            -H "Tags: white_check_mark" \
            -d "$STATS in $DURATION" \
            "$NTFY_URL"
          touch ${statusDir}/unifi || true
        fi
      '';
    };

    systemd.services.restic-backups-unifi = {
      unitConfig = {
        RequiresMountsFor = "/mnt/unas_homelab";
        OnFailure = "restic-backups-unifi-notify-failure.service";
      };
    };

    systemd.services.restic-backups-unifi-notify-failure = {
      description = "Notify on restic-backups-unifi failure";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "restic-unifi-notify-failure" ''
          NTFY_URL="$(cat /var/lib/opnix/secrets/ntfyUrl)"
          ${pkgs.curl}/bin/curl -s -o /dev/null \
            -H "Title: Homelab / Backup / UniFi" \
            -H "Tags: x" \
            -H "Priority: high" \
            -d "Backup FAILED — check journalctl -u restic-backups-unifi" \
            "$NTFY_URL"
        '';
      };
    };
  };
}
