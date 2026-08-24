{
  config,
  pkgs,
  lib,
  ...
}:
let
  # 4.0.1, ahead of nixpkgs, for its UNAS input. See pkgs/unpoller.nix.
  unpoller = pkgs.callPackage ../../pkgs/unpoller.nix { };

  port = 9130;

  unasUrl = "https://${config.my.nas.ip}";

  # Literal address, not pi-3.local. mDNS resolution needs the resolver socket, which
  # RestrictAddressFamilies below denies — the unit fails with "lookup pi-3.local:
  # device or resource busy".
  #
  # lanIp rather than tailscaleIp: both pis sit on the same switch, so the tailnet
  # would be a pointless hop, and it would make controller metrics depend on tailscaled
  # being up. The kula backends in sites/lab.oschrenk.gt.nix use the tailnet because
  # Traefik publishes them onward, which does not apply here.
  unifiUrl = "https://${config.my.host."pi-3".lanIp}:8443";

  unasPasswordFile = "/var/lib/opnix/secrets/unpollerUnasPassword";
  unifiPasswordFile = "/var/lib/opnix/secrets/unpollerUnifiPassword";

  # The nixpkgs module targets unpoller 3.x and knows nothing about [unas], so the
  # config is written here instead. It holds no secrets: the controller password is a
  # file:// reference, and the UNAS device is supplied entirely through the environment.
  configFile = (pkgs.formats.toml { }).generate "unpoller.conf" {
    poller = {
      debug = false;
      quiet = false;
    };

    prometheus = {
      disable = false;
      # localhost only — Prometheus runs on this host and scrapes over loopback.
      http_listen = "127.0.0.1:${toString port}";
      namespace = "unpoller";
    };

    influxdb.disable = true;
    datadog.disable = true;
    loki.disable = true;

    # inputunifi resolves file:// itself (pkg/inputunifi/input.go:363), so the
    # controller password never needs to reach the environment or the store.
    unifi = {
      disable = false;
      dynamic = false;
      defaults = {
        url = unifiUrl;
        # Not a secret, so it stays in the config rather than the environment. The
        # matching password is op://Homelab/spjanmeqbrmygc5e2ijapwzkhe/password.
        # This account must hold a role on the site — an admin with no site membership
        # authenticates, reports controller_up 1, and polls nothing.
        user = "unifi.local";
        pass = "file://${unifiPasswordFile}";
        verify_ssl = false;
        save_sites = true;
      };
    };

    # Devices deliberately omitted — see the ExecStart wrapper. inputunas has no
    # file:// handling, so its password can only arrive via the environment.
    unas.enable = true;
  };

  start = pkgs.writeShellScript "unpoller-start" ''
    set -euo pipefail

    # Command substitution strips the trailing newline opnix leaves on the file.
    # Omitting USER is not an error: inputunas falls back to the built-in default
    # "unpoller" and fails with a 403, which looks like a credential problem rather
    # than a configuration one.
    export UP_UNAS_ENABLE=true
    export UP_UNAS_DEVICE_0_URL="${unasUrl}"
    export UP_UNAS_DEVICE_0_USER="unas.local"
    export UP_UNAS_DEVICE_0_PASS="$(cat ${unasPasswordFile})"
    export UP_UNAS_DEVICE_0_VERIFY_SSL=false

    exec ${unpoller}/bin/unpoller --config ${configFile}
  '';
in
{
  config = {
    users.groups.unpoller = { };
    users.users.unpoller = {
      description = "unpoller service user";
      group = "unpoller";
      isSystemUser = true;
    };

    systemd.services.unpoller = {
      description = "UniFi Poller — controller and UNAS metrics for Prometheus";
      wantedBy = [ "multi-user.target" ];

      # Both passwords come from opnix, so the same race that broke perses applies:
      # without this the unit starts before the secrets exist and fails on a missing
      # file rather than retrying.
      after = [
        "network-online.target"
        "opnix-secrets.service"
      ];
      wants = [ "network-online.target" ];
      requires = [ "opnix-secrets.service" ];

      serviceConfig = {
        ExecStart = start;
        User = "unpoller";
        Group = "unpoller";
        Restart = "on-failure";
        RestartSec = 30;

        # Hardening. No state, no writes, one outbound HTTPS client.
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
    };

    # Scraped over loopback by the Prometheus on this host.
    services.prometheus.scrapeConfigs = [
      {
        job_name = "unpoller";
        static_configs = [ { targets = [ "127.0.0.1:${toString port}" ]; } ];
      }
    ];
  };
}
