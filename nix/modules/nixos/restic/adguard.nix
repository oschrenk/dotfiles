{ config, pkgs, lib, ... }:
let
  cfg       = config.services.restic-adguard;
  statusDir = config.services.backup-healthcheck.statusDir;
in
{
  options.services.restic-adguard.backupSchedule = lib.mkOption {
    type        = lib.types.str;
    default     = "daily";
    description = "OnCalendar value for the restic timer. Override per-host to stagger with other backups.";
  };

  config = {
    services.restic.backups.adguard = {
      # AdGuard uses DynamicUser=true — systemd stores data in /var/lib/private/AdGuardHome
      # and bind-mounts it to /var/lib/AdGuardHome only while the service is running.
      # Backing up the private path directly avoids depending on the bind mount being active.
      paths        = [ "/var/lib/private/AdGuardHome" ];
      repository   = "/mnt/unas_backup/restic-pi1";  # same repo as beszel
      passwordFile = "/var/lib/opnix/secrets/resticPassword";
      timerConfig  = { OnCalendar = cfg.backupSchedule; Persistent = true; };
      # Retention policy intentionally mirrors restic-beszel.nix — change both
      # together if adjusting. 7 daily + 4 weekly snapshots.
      pruneOpts    = [ "--keep-daily 7" "--keep-weekly 4" ];
      initialize   = true;

      # AdGuard Home is NOT stopped before backup, unlike beszel-hub. Reasons:
      #   1. DNS availability: stopping takes the whole network's DNS down for ~30s.
      #   2. Data is low-value: stats.db and querylog.json losing a few seconds of
      #      DNS query history is acceptable.
      #   3. Config (AdGuardHome.yaml) is fully reproducible from Nix — no need
      #      for a consistent runtime snapshot.
      backupPrepareCommand = ''
        # /run is a root-owned tmpfs cleared on reboot — safer than /tmp (world-writable).
        date +%s > /run/restic-adguard-start
      '';

      # backupCleanupCommand maps to ExecStopPost — runs on success or failure of the
      # service itself, but NOT when the service fails to start due to a dependency
      # (e.g. RequiresMountsFor). Failure notifications for dependency failures are
      # handled by the OnFailure= unit below.
      backupCleanupCommand = ''
        if [ "$SERVICE_RESULT" = "success" ]; then
          NTFY_URL="$(cat /var/lib/opnix/secrets/ntfyUrl)"
          START="$(cat /run/restic-adguard-start 2>/dev/null || echo 0)"
          NOW="$(date +%s)"
          DURATION="$((NOW - START))s"
          STATS="$(${pkgs.systemd}/bin/journalctl -u restic-backups-adguard.service \
            --since "@$START" --no-pager --output=cat 2>/dev/null \
            | grep "processed [0-9]* files," | tail -1 \
            | sed 's/processed \([0-9]*\) files, \([0-9]*\)\.[0-9]* \([A-Za-z]*\) in [0-9]*:[0-9]*/\1 files (\2 \3)/')"
          ${pkgs.curl}/bin/curl -s -o /dev/null \
            -H "Title: Homelab / Backup / AdGuard Home" \
            -H "Tags: white_check_mark" \
            -d "$STATS in $DURATION" \
            "$NTFY_URL"
          touch ${statusDir}/adguard || true
        fi
      '';
    };

    # RequiresMountsFor ensures the service fails immediately if the CIFS mount is
    # not available. Without this, restic's initialize=true would create a new local
    # repo on the bare mount point directory and back up to the Pi's SD card instead
    # of the NAS — appearing to succeed while writing nothing to the NAS.
    #
    # OnFailure= handles failure notifications for ALL failure modes, including
    # dependency failures (e.g. NAS unreachable) where ExecStopPost never runs.
    systemd.services.restic-backups-adguard = {
      unitConfig = {
        RequiresMountsFor = "/mnt/unas_backup";
        OnFailure         = "restic-backups-adguard-notify-failure.service";
      };
    };

    # Sends failure ntfy notification. Triggered via OnFailure= so it fires even
    # when the backup service fails to start (e.g. NAS mount unavailable).
    systemd.services.restic-backups-adguard-notify-failure = {
      description = "Notify on restic-backups-adguard failure";
      serviceConfig = {
        Type      = "oneshot";
        ExecStart = pkgs.writeShellScript "restic-adguard-notify-failure" ''
          NTFY_URL="$(cat /var/lib/opnix/secrets/ntfyUrl)"
          ${pkgs.curl}/bin/curl -s -o /dev/null \
            -H "Title: Homelab / Backup / AdGuard Home" \
            -H "Tags: x" \
            -H "Priority: high" \
            -d "Backup FAILED — check journalctl -u restic-backups-adguard" \
            "$NTFY_URL"
        '';
      };
    };
  };
}
