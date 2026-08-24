{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.restic-fusion;
  statusDir = config.services.backup-healthcheck.statusDir;
  snapshot = "/var/lib/fusion/snapshot.db";
in
{
  options.services.restic-fusion.backupSchedule = lib.mkOption {
    type = lib.types.str;
    default = "daily";
    description = "OnCalendar value for the restic timer. Override per-host to stagger with other backups.";
  };

  config = {
    services.restic.backups.fusion = {
      paths = [ snapshot ];
      repository = "/mnt/unas_homelab/restic";
      passwordFile = "/var/lib/opnix/secrets/resticPassword";
      timerConfig = {
        OnCalendar = cfg.backupSchedule;
        Persistent = true;
      };
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
      ];
      initialize = true;

      backupPrepareCommand = ''
        date +%s > /run/restic-fusion-start
        rm -f ${snapshot}
        ${pkgs.sqlite}/bin/sqlite3 ${config.services.fusion.dbPath} ".backup '${snapshot}'"
      '';

      backupCleanupCommand = ''
        if [ "$SERVICE_RESULT" = "success" ]; then
          NTFY_URL="$(cat /var/lib/opnix/secrets/ntfyUrl)"
          START="$(cat /run/restic-fusion-start 2>/dev/null || echo 0)"
          NOW="$(date +%s)"
          DURATION="$((NOW - START))s"
          STATS="$(${pkgs.systemd}/bin/journalctl -u restic-backups-fusion.service \
            --since "@$START" --no-pager --output=cat 2>/dev/null \
            | grep "processed [0-9]* files," | tail -1 \
            | sed 's/processed \([0-9]*\) files, \([0-9]*\)\.[0-9]* \([A-Za-z]*\) in [0-9]*:[0-9]*/\1 files (\2 \3)/')"
          ${pkgs.curl}/bin/curl -s -o /dev/null \
            -H "Title: Homelab / Backup / fusion" \
            -H "Tags: white_check_mark" \
            -d "$STATS in $DURATION" \
            "$NTFY_URL"
          touch ${statusDir}/fusion || true
        fi
        rm -f ${snapshot}
      '';
    };

    systemd.services.restic-backups-fusion = {
      unitConfig = {
        RequiresMountsFor = "/mnt/unas_homelab";
        OnFailure = "restic-backups-fusion-notify-failure.service";
      };
    };

    systemd.services.restic-backups-fusion-notify-failure = {
      description = "Notify on restic-backups-fusion failure";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "restic-fusion-notify-failure" ''
          NTFY_URL="$(cat /var/lib/opnix/secrets/ntfyUrl)"
          ${pkgs.curl}/bin/curl -s -o /dev/null \
            -H "Title: Homelab / Backup / fusion" \
            -H "Tags: x" \
            -H "Priority: high" \
            -d "Backup FAILED — check journalctl -u restic-backups-fusion" \
            "$NTFY_URL"
        '';
      };
    };
  };
}
