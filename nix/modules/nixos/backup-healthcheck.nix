{ config, pkgs, lib, ... }:
let
  cfg = config.services.backup-healthcheck;

  healthcheck = pkgs.writeShellScript "backup-healthcheck" ''
    if [ -f "${cfg.timestampFile}" ]; then
      NOW=$(${pkgs.coreutils}/bin/date +%s)
      MTIME=$(${pkgs.coreutils}/bin/stat -c %Y "${cfg.timestampFile}")
      AGE=$((NOW - MTIME))
      if [ "$AGE" -lt "${toString cfg.maxAge}" ]; then
        STATUS="200 OK"; BODY="OK"
      else
        STATUS="503 Service Unavailable"; BODY="STALE"
      fi
    else
      STATUS="503 Service Unavailable"; BODY="MISSING"
    fi

    printf "HTTP/1.1 %s\r\nContent-Length: %s\r\nConnection: close\r\n\r\n%s" \
      "$STATUS" "''${#BODY}" "$BODY"
  '';
in
{
  options.services.backup-healthcheck = {
    enable = lib.mkEnableOption "backup freshness HTTP endpoint";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8099;
      description = "localhost port the shim listens on";
    };

    maxAge = lib.mkOption {
      type = lib.types.int;
      default = 90000; # 25 hours in seconds
      description = "seconds since last successful backup before returning 503";
    };

    timestampFile = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/backup-status/beszel";
      description = "file touched by the backup job on success";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      # directory is derived from timestampFile so it follows any override
      "d ${builtins.dirOf cfg.timestampFile} 0755 root root -"
    ];

    systemd.sockets.backup-healthcheck = {
      wantedBy = [ "sockets.target" ];
      socketConfig = {
        ListenStream = "127.0.0.1:${toString cfg.port}";
        Accept = true;
      };
    };

    systemd.services."backup-healthcheck@" = {
      serviceConfig = {
        Type = "simple";
        ExecStart = "${healthcheck}";
        StandardInput = "socket";
        StandardOutput = "socket";
        StandardError = "journal";
      };
    };
  };
}
