{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.restic-offsite;
  statusDir = config.services.backup-healthcheck.statusDir;

  # Source is the shared repo every host writes into. The copy runs unfiltered —
  # no --host, no --path — so a newly onboarded Pi is covered with no change here.
  source = "/mnt/unas_homelab/restic";

  # Cloudflare R2, EU jurisdiction. Bucket names allow no dots, so the domain-ish
  # name is hyphenated. See tasks/DOTFILES-05-homelab-hardening.md section 1.
  destination = "s3:https://cc43301dd82d0d62d084b2c945273463.eu.r2.cloudflarestorage.com/oschrenk-lab-restic";

  # Both repos share one password. They still have different master keys — each is
  # generated at init — which is why copy must decrypt and re-encrypt rather than
  # streaming ciphertext. One password is one secret to lose, and both repos hold
  # the same data anyway, so a second one would buy nothing.
  passwordFile = "/var/lib/opnix/secrets/resticPassword";

  restic = "${pkgs.restic}/bin/restic";
in
{
  options.services.restic-offsite.schedule = lib.mkOption {
    type = lib.types.str;
    default = "*-*-* 03:00:00";
    description = "OnCalendar value for the offsite copy. Must run after the last local backup so it never copies mid-write.";
  };

  config = {
    systemd.timers.restic-offsite = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true; # run a missed copy after downtime
      };
    };

    systemd.services.restic-offsite = {
      description = "Copy the UNAS restic repo to Cloudflare R2";

      unitConfig = {
        # Same guard as the local jobs. Without it the unit would run against a bare
        # mount point directory, find no repo, and fail in a less obvious way.
        RequiresMountsFor = source;
        OnFailure = "restic-offsite-notify-failure.service";
      };

      serviceConfig = {
        Type = "oneshot";
        # restic caches the destination index here, so steady-state runs barely read
        # from R2 at all — only new snapshots and their blobs move.
        CacheDirectory = "restic-offsite";
      };

      environment = {
        RESTIC_CACHE_DIR = "/var/cache/restic-offsite";
        RESTIC_FROM_REPOSITORY = source;
        RESTIC_FROM_PASSWORD_FILE = passwordFile;
        RESTIC_REPOSITORY = destination;
        RESTIC_PASSWORD_FILE = passwordFile;
      };

      script = ''
        set -euo pipefail

        # Command substitution strips the trailing newline opnix leaves on the file;
        # a stray newline in either credential fails R2 auth with a bare 403.
        export AWS_ACCESS_KEY_ID="$(cat /var/lib/opnix/secrets/resticR2KeyId)"
        export AWS_SECRET_ACCESS_KEY="$(cat /var/lib/opnix/secrets/resticR2Secret)"

        START="$(date +%s)"

        # Stale locks survive a killed restic process and would block both operations.
        # unlock only removes locks whose owning process is gone, so this is safe to
        # run unconditionally.
        ${restic} unlock --repo "$RESTIC_FROM_REPOSITORY" --password-file ${passwordFile}
        ${restic} unlock

        # No --host or --path: copy everything the source holds. Snapshots already in
        # the destination are skipped via their `original` field, so re-runs are cheap.
        LOG="$(mktemp)"
        trap 'rm -f "$LOG"' EXIT
        # --retry-lock for the same reason as the local jobs: copy takes a shared lock
        # on the source, which an overrunning local prune still blocks.
        ${restic} copy --retry-lock 5m 2>&1 | tee "$LOG"
        COPIED="$(grep -c 'snapshot .* saved' "$LOG" || true)"

        # Retention applies to R2 only — RESTIC_REPOSITORY is the destination, and
        # forget has no notion of the copy source. Deliberately longer than the local
        # 7d/4w so the bucket keeps history the UNAS repo has already pruned.
        ${restic} forget --prune \
          --retry-lock 5m \
          --keep-daily 7 \
          --keep-weekly 4 \
          --keep-monthly 3

        DURATION="$(( $(date +%s) - START ))s"
        NTFY_URL="$(cat /var/lib/opnix/secrets/ntfyUrl)"
        ${pkgs.curl}/bin/curl -s -o /dev/null \
          -H "Title: Homelab / Backup / Offsite" \
          -H "Tags: white_check_mark" \
          -d "$COPIED snapshots copied to R2 in $DURATION" \
          "$NTFY_URL"

        touch ${statusDir}/offsite || true
      '';
    };

    # Fires for every failure mode, including the unit never starting because the
    # CIFS mount is unavailable — where an ExecStopPost would not run.
    systemd.services.restic-offsite-notify-failure = {
      description = "Notify on restic-offsite failure";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "restic-offsite-notify-failure" ''
          NTFY_URL="$(cat /var/lib/opnix/secrets/ntfyUrl)"
          ${pkgs.curl}/bin/curl -s -o /dev/null \
            -H "Title: Homelab / Backup / Offsite" \
            -H "Tags: x" \
            -H "Priority: high" \
            -d "Offsite copy FAILED — check journalctl -u restic-offsite" \
            "$NTFY_URL"
        '';
      };
    };
  };
}
