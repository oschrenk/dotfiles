{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.restic-gatus;
in
{
  options.services.restic-gatus.backupSchedule = lib.mkOption {
    type = lib.types.str;
    default = "daily";
    description = "OnCalendar value for the restic timer. Override per-host without touching this module.";
  };

  config = {
    services.restic.backups.gatus = {
      # The real directory, not /var/lib/gatus: gatus runs with DynamicUser,
      # which makes /var/lib/gatus a symlink into /var/lib/private, and restic
      # archives a bare symlink as 0 bytes without a word of complaint.
      paths = [ "/var/lib/private/gatus" ];
      repository = "/mnt/unas_homelab/restic";
      passwordFile = "/var/lib/opnix/secrets/resticPassword";

      timerConfig = {
        OnCalendar = cfg.backupSchedule;
        Persistent = true; # run missed backups after downtime
      };

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
        # Matches the 5-minute schedule gap in hosts/pi-1.nix: a job may absorb one
        # slot of delay from its predecessor and no more. Without it restic fails
        # immediately on a held lock, and `forget --prune` takes an exclusive one.
        "--retry-lock 5m"
      ];

      # gatus is NOT stopped before backup: check history is low-value enough
      # that a snapshot mid-write costing one row beats a monitoring gap.
      backupPrepareCommand = ''
        date +%s > /tmp/restic-gatus-start
      '';

      backupCleanupCommand = ''
        if [ "$SERVICE_RESULT" = "success" ]; then
          NTFY_URL="$(cat /var/lib/opnix/secrets/ntfyUrl)"
          START="$(cat /tmp/restic-gatus-start 2>/dev/null || echo 0)"
          NOW="$(date +%s)"
          DURATION="$((NOW - START))s"
          STATS="$(${pkgs.systemd}/bin/journalctl -u restic-backups-gatus.service --since "@$START" --no-pager --output=cat 2>/dev/null | grep "processed [0-9]* files," | tail -1 | sed 's/processed \([0-9]*\) files, \([0-9]*\)\.[0-9]* \([A-Za-z]*\) in [0-9]*:[0-9]*/\1 files (\2 \3)/')"
          ${pkgs.curl}/bin/curl -s -o /dev/null \
            -H "Title: Homelab / Backup / Gatus" \
            -H "Tags: white_check_mark" \
            -d "$STATS in $DURATION" \
            "$NTFY_URL"
          touch ${config.services.backup-healthcheck.statusDir}/gatus || true
        fi
      '';

      initialize = true; # runs `restic init` on first start if repo is empty
      extraBackupArgs = [ "--retry-lock 5m" ];
    };

    # Same shape as the other restic jobs: fail fast when the NAS mount is
    # absent rather than initialize a repo on the SD card, and notify on every
    # failure mode through OnFailure=, which fires even when ExecStopPost
    # cannot.
    systemd.services.restic-backups-gatus = {
      unitConfig = {
        RequiresMountsFor = "/mnt/unas_homelab";
        OnFailure = "restic-backups-gatus-notify-failure.service";
      };
    };

    systemd.services.restic-backups-gatus-notify-failure = {
      description = "Notify on restic-backups-gatus failure";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "restic-gatus-notify-failure" ''
          NTFY_URL="$(cat /var/lib/opnix/secrets/ntfyUrl)"
          ${pkgs.curl}/bin/curl -s -o /dev/null \
            -H "Title: Homelab / Backup / Gatus" \
            -H "Tags: x" \
            -H "Priority: high" \
            -d "Backup FAILED — check journalctl -u restic-backups-gatus" \
            "$NTFY_URL"
        '';
      };
    };
  };
}
