{ config, lib, pkgs, ... }:
let
  cfg = config.services.kula;
  kula = pkgs.callPackage ../../pkgs/kula.nix { };

  # 100M budget: ~2 days at 1s, ~4 weeks at 1m, ~6 months at 5m. Resolutions are
  # upstream defaults — coarser ones raise RAM, since more samples buffer per window.
  configFile = (pkgs.formats.yaml { }).generate "kula-config.yaml" {
    # Drops the Space Invaders button from the header.
    global.easter_egg = false;
    collection.interval = "1s";
    storage = {
      directory = cfg.dataDir;
      tiers = [
        { resolution = "1s"; max_size = "64MB"; }
        { resolution = "1m"; max_size = "16MB"; }
        { resolution = "5m"; max_size = "20MB"; }
      ];
    };
    web = {
      enabled = true;
      # Separate switch from `enabled`: ui = false still serves /health and
      # /metrics, so the gatus check would pass with a dead dashboard.
      ui = true;
      listen = cfg.listenAddress;
      port = cfg.port;
      trust_proxy = true;
      prometheus_metrics.enabled = true;
    };
  };
in
{
  options.services.kula = {
    port = lib.mkOption {
      type = lib.types.port;
      default = 27960;
      description = "Port kula listens on, localhost only — Traefik proxies it.";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = ''
        Address kula binds. Default suits the host running Traefik. Hosts whose
        dashboard is proxied from elsewhere need "0.0.0.0" — the firewall is the
        boundary there, since base.nix opens no LAN ports and trusts tailscale0,
        so only the tailnet can reach it.
      '';
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/run/kula";
      description = "Ring-buffer directory. tmpfs, to spare the boot media.";
    };
  };

  config = {
    systemd.services.kula = {
      description = "Kula server monitoring";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        ExecStart = "${lib.getExe kula} -config ${configFile}";
        Restart = "always";
        RestartSec = 5;

        # No secrets, so no need for the static user beszel/fusion need for opnix.
        DynamicUser = true;

        RuntimeDirectory = "kula";
        RuntimeDirectoryMode = "0750";
        # Without this the history is wiped on every deploy.
        RuntimeDirectoryPreserve = "yes";
        WorkingDirectory = cfg.dataDir;

        # kula confines itself with Landlock (/proc + /sys read-only, storage dir
        # read-write), so don't add ProtectProc or ProtectKernelTunables here —
        # they would blank out thermal, disk and process metrics silently.
        NoNewPrivileges = true;
        RestrictSUIDSGID = true;
      };
    };
  };
}
