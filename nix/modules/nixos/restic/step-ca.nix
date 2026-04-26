{ config, pkgs, lib, ... }:
let
  cfg       = config.services.restic-step-ca;
  statusDir = config.services.backup-healthcheck.statusDir;
in
{
  options.services.restic-step-ca.backupSchedule = lib.mkOption {
    type        = lib.types.str;
    default     = "daily";
    description = "OnCalendar value for the restic timer. Override per-host to stagger with other backups.";
  };

  config = {
    services.restic.backups.step-ca = {
      # Backs up the full .step/ tree: certs, secrets (private keys), config, db.
      # The private keys are the critical part — losing them means re-bootstrapping
      # the CA and re-trusting the root cert on every device.
      paths        = [ "/var/lib/step-ca/.step" ];
      repository   = "/mnt/unas_backup/restic-pi1";
      passwordFile = "/var/lib/opnix/secrets/resticPassword";
      timerConfig  = { OnCalendar = cfg.backupSchedule; Persistent = true; };
      pruneOpts    = [ "--keep-daily 7" "--keep-weekly 4" ];
      initialize   = true;

      backupPrepareCommand = ''
        date +%s > /run/restic-step-ca-start
      '';

      backupCleanupCommand = ''
        if [ "$SERVICE_RESULT" = "success" ]; then
          NTFY_URL="$(cat /var/lib/opnix/secrets/ntfyUrl)"
          START="$(cat /run/restic-step-ca-start 2>/dev/null || echo 0)"
          NOW="$(date +%s)"
          DURATION="$((NOW - START))s"
          STATS="$(${pkgs.systemd}/bin/journalctl -u restic-backups-step-ca.service \
            --since "@$START" --no-pager --output=cat 2>/dev/null \
            | grep "processed [0-9]* files," | tail -1 \
            | sed 's/processed \([0-9]*\) files, \([0-9]*\)\.[0-9]* \([A-Za-z]*\) in [0-9]*:[0-9]*/\1 files (\2 \3)/')"
          ${pkgs.curl}/bin/curl -s -o /dev/null \
            -H "Title: Homelab / Backup / step-ca" \
            -H "Tags: white_check_mark" \
            -d "$STATS in $DURATION" \
            "$NTFY_URL"
          touch ${statusDir}/step-ca || true
        fi
      '';
    };

    systemd.services.restic-backups-step-ca = {
      unitConfig = {
        RequiresMountsFor = "/mnt/unas_backup";
        OnFailure         = "restic-backups-step-ca-notify-failure.service";
      };
    };

    systemd.services.restic-backups-step-ca-notify-failure = {
      description = "Notify on restic-backups-step-ca failure";
      serviceConfig = {
        Type      = "oneshot";
        ExecStart = pkgs.writeShellScript "restic-step-ca-notify-failure" ''
          NTFY_URL="$(cat /var/lib/opnix/secrets/ntfyUrl)"
          ${pkgs.curl}/bin/curl -s -o /dev/null \
            -H "Title: Homelab / Backup / step-ca" \
            -H "Tags: x" \
            -H "Priority: high" \
            -d "Backup FAILED — check journalctl -u restic-backups-step-ca" \
            "$NTFY_URL"
        '';
      };
    };
  };
}
