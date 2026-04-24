{ config, pkgs, lib, ... }:
let
  cfg = config.services.backup-healthcheck;

  # Generates the per-connection shell script that checks the timestamp file and
  # returns an HTTP 1.1 response. Parameterised so each check gets its own script
  # with its own path and maxAge baked in at build time.
  makeHealthcheckScript = timestampFile: maxAge: pkgs.writeShellScript "backup-healthcheck" ''
    if [ -f "${timestampFile}" ]; then
      NOW=$(${pkgs.coreutils}/bin/date +%s)
      MTIME=$(${pkgs.coreutils}/bin/stat -c %Y "${timestampFile}")
      AGE=$((NOW - MTIME))
      if [ "$AGE" -lt "${toString maxAge}" ]; then
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
    statusDir = lib.mkOption {
      type    = lib.types.path;
      default = "/var/lib/backup-status";
      description = "Root dir for all backup timestamp files. Change once to move all paths.";
    };

    checks = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
        options = {
          port = lib.mkOption {
            type = lib.types.port;
          };
          # 90000 = 25 hours in seconds (25 × 3600). Slightly over 24h to tolerate
          # a backup that runs a few minutes late without false-alerting.
          maxAge = lib.mkOption {
            type        = lib.types.int;
            default     = 90000;
            description = "Max age in seconds before returning 503 (default: 25h = 90000s).";
          };
          # null = derive path from statusDir/name; set explicitly only to override.
          timestampFile = lib.mkOption {
            type    = lib.types.nullOr lib.types.path;
            default = null;
          };
        };
      }));
      default = {};
      description = "Named backup checks. Module activates when non-empty.";
    };
  };

  config = lib.mkIf (cfg.checks != {}) {
    systemd.tmpfiles.rules = [ "d ${cfg.statusDir} 0755 root root -" ];

    systemd.sockets = lib.mapAttrs' (name: check:
      lib.nameValuePair "backup-healthcheck-${name}" {
        wantedBy = [ "sockets.target" ];
        socketConfig = {
          ListenStream = "127.0.0.1:${toString check.port}";
          # Accept = true: spawn a new instance per connection. Required for the
          # backup-healthcheck-${name}@ instantiated service pattern.
          Accept = true;
        };
      }
    ) cfg.checks;

    systemd.services = lib.mapAttrs' (name: check:
      let
        effectivePath = if check.timestampFile != null
                        then check.timestampFile
                        else "${cfg.statusDir}/${name}";
      in lib.nameValuePair "backup-healthcheck-${name}@" {
        serviceConfig = {
          Type           = "simple";
          ExecStart      = makeHealthcheckScript effectivePath check.maxAge;
          StandardInput  = "socket";
          StandardOutput = "socket";
          StandardError  = "journal";
        };
      }
    ) cfg.checks;
  };
}
