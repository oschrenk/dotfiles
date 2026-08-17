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
      description = ''
        Port fusion listens on. Upstream binds all interfaces and offers no
        bind-host setting, so exposure is controlled by the firewall: only 443
        is open to the LAN, while tailscale0 is a trustedInterface (base.nix)
        and can reach this port directly.
      '';
    };

    dbPath = lib.mkOption {
      type = lib.types.str;
      default = "${dataDir}/fusion.db";
      description = "SQLite database file. The whole application state lives here.";
    };
  };

  config = {
    users.users.fusion = {
      isSystemUser = true;
      group = "fusion";
    };
    users.groups.fusion = { };

    # Fusion reads its password from FUSION_PASSWORD, but opnix stores the bare
    # value. Same shape as gatus-env: turn the secret into a systemd env file.
    systemd.services.fusion-env = {
      description = "Write fusion environment file from opnix secrets";
      before = [ "fusion.service" ];
      after = [ opnixUnit ];
      requires = [ opnixUnit ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "fusion-env" ''
          echo "FUSION_PASSWORD=$(cat /var/lib/opnix/secrets/fusionPassword)" > ${envFile}
          chmod 600 ${envFile}
        '';
      };
    };

    systemd.services.fusion = {
      description = "Fusion RSS reader";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network-online.target"
        "fusion-env.service"
      ];
      wants = [ "network-online.target" ];
      requires = [ "fusion-env.service" ];

      environment = {
        FUSION_PORT = toString cfg.port;
        FUSION_DB_PATH = cfg.dbPath;
        # Traefik is the only proxy in front of fusion; trusting it means the
        # login rate limiter sees real client IPs instead of 127.0.0.1.
        FUSION_TRUSTED_PROXIES = "127.0.0.1";
      };

      serviceConfig = {
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
