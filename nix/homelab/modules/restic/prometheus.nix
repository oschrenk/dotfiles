{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.restic-prometheus;
  statusDir = config.services.backup-healthcheck.statusDir;
  dataDir = "/var/lib/prometheus2";
in
{
  options.services.restic-prometheus.backupSchedule = lib.mkOption {
    type = lib.types.str;
    default = "daily";
    description = "OnCalendar value for the restic timer. Override per-host to stagger with other backups.";
  };

  config = {
    services.restic.backups.prometheus = {
      paths = [ dataDir ];

      # wal and chunks_head are the head block: in memory, still being written, and
      # not coherent when copied file by file. Excluding them leaves only persistent
      # blocks, which are written every ~2h and never modified afterwards, so the
      # snapshot is consistent by construction rather than by luck.
      #
      # The cost is quoted by the Prometheus storage docs: "Backups made without
      # snapshots run the risk of losing data that was recorded since the last TSDB
      # block was created, which typically happens every two hours, covering the last
      # three hours of samples." At a 60s scrape that is ~180 samples out of ~130,000
      # over the 90-day window.
      #
      # The admin snapshot API loses none of that, and was rejected anyway: it needs
      # --web.enable-admin-api on permanently, which also exposes delete_series and
      # clean_tombstones, to serve a job that runs once a night.
      exclude = [
        "${dataDir}/data/wal"
        "${dataDir}/data/chunks_head"
      ];

      repository = "/mnt/unas_homelab/restic";
      passwordFile = "/var/lib/opnix/secrets/resticPassword";

      timerConfig = {
        OnCalendar = cfg.backupSchedule;
        Persistent = true;
      };

      # Same policy as the pi-1 jobs and the offsite copy — change all together.
      # forget groups by host,paths by default, so pi-2's snapshots are retained
      # independently of pi-1's despite sharing one repository.
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
        "--retry-lock 5m"
      ];

      extraBackupArgs = [ "--retry-lock 5m" ];

      initialize = true;

      backupPrepareCommand = ''
        date +%s > /run/restic-prometheus-start
      '';

      backupCleanupCommand = ''
        if [ "$SERVICE_RESULT" = "success" ]; then
          NTFY_URL="$(cat /var/lib/opnix/secrets/ntfyUrl)"
          START="$(cat /run/restic-prometheus-start 2>/dev/null || echo 0)"
          NOW="$(date +%s)"
          DURATION="$((NOW - START))s"
          STATS="$(${pkgs.systemd}/bin/journalctl -u restic-backups-prometheus.service \
            --since "@$START" --no-pager --output=cat 2>/dev/null \
            | grep "processed [0-9]* files," | tail -1 \
            | sed 's/processed \([0-9]*\) files, \([0-9]*\)\.[0-9]* \([A-Za-z]*\) in [0-9]*:[0-9]*/\1 files (\2 \3)/')"
          ${pkgs.curl}/bin/curl -s -o /dev/null \
            -H "Title: Homelab / Backup / Prometheus" \
            -H "Tags: white_check_mark" \
            -d "$STATS in $DURATION" \
            "$NTFY_URL"
          touch ${statusDir}/prometheus || true
        fi
      '';
    };

    systemd.services.restic-backups-prometheus = {
      unitConfig = {
        RequiresMountsFor = "/mnt/unas_homelab";
        OnFailure = "restic-backups-prometheus-notify-failure.service";
      };
    };

    systemd.services.restic-backups-prometheus-notify-failure = {
      description = "Notify on restic-backups-prometheus failure";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "restic-prometheus-notify-failure" ''
          NTFY_URL="$(cat /var/lib/opnix/secrets/ntfyUrl)"
          ${pkgs.curl}/bin/curl -s -o /dev/null \
            -H "Title: Homelab / Backup / Prometheus" \
            -H "Tags: x" \
            -H "Priority: high" \
            -d "Backup FAILED — check journalctl -u restic-backups-prometheus" \
            "$NTFY_URL"
        '';
      };
    };
  };
}
