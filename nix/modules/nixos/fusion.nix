{ config, lib, pkgs, ... }:
let
  cfg = config.services.fusion;
  fusion = pkgs.callPackage ../../pkgs/fusion.nix { };
  dataDir = "/var/lib/fusion";
  envFile = "/run/fusion.env";
  opnixUnit = "opnix-secrets.service";
in
{
  options.services.fusion = {
    port = lib.mkOption {
      type = lib.types.port;
      default = 8083;
      description = "Port fusion listens on.";
    };

    dbPath = lib.mkOption {
      type = lib.types.str;
      default = "${dataDir}/fusion.db";
      description = "Path to the SQLite database file.";
    };
  };

  config = {
    users.users.fusion = {
      isSystemUser = true;
      group = "fusion";
    };
    users.groups.fusion = { };

    systemd.services.fusion = {
      description = "Fusion RSS reader";
      wantedBy = [ "multi-user.target" ];
      # opnix is only wanted, so a boot with no WAN still starts fusion from
      # the cached secret.
      after = [
        "network-online.target"
        opnixUnit
      ];
      wants = [
        "network-online.target"
        opnixUnit
      ];

      environment = {
        FUSION_PORT = toString cfg.port;
        FUSION_DB_PATH = cfg.dbPath;
        FUSION_FEVER_USERNAME = config.my.personal.email;
        FUSION_TRUSTED_PROXIES = "127.0.0.1";
      };

      serviceConfig = {
        # "+" runs the pre-start as root, so the secret and the env file stay
        # root-only while the daemon runs unprivileged. It runs on every start,
        # so a restart always reads the current secret.
        ExecStartPre = "+"
          + pkgs.writeShellScript "fusion-env" ''
            set -eu
            umask 077
            echo "FUSION_PASSWORD=$(cat /var/lib/opnix/secrets/fusionPassword)" > ${envFile}
          '';
        ExecStart = lib.getExe fusion;
        EnvironmentFile = envFile;
        User = "fusion";
        Group = "fusion";
        Restart = "always";
        RestartSec = 5;

        StateDirectory = "fusion";
        StateDirectoryMode = "0700";
        WorkingDirectory = dataDir;

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
      };
    };
  };
}
