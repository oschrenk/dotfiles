{ config, pkgs, ... }:
let
  shimPort = config.services.backup-healthcheck.checks.beszel.port;
  opnixUnit = "opnix-secrets.service";
in
{
  systemd.services.gatus-env = {
    description = "Write Gatus environment file from opnix secrets";
    before = [ "gatus.service" ];
    after = [ opnixUnit ];
    requires = [ opnixUnit ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "gatus-env" ''
        echo "NTFY_URL=$(cat /var/lib/opnix/secrets/ntfyUrl)" > /run/gatus.env
        chmod 644 /run/gatus.env
      '';
    };
  };

  systemd.services.gatus = {
    after = [
      "gatus-env.service"
      "backup-healthcheck-beszel.socket"
      "backup-healthcheck-adguard.socket"
    ];
    requires = [ "gatus-env.service" ];
  };

  services.gatus = {
    enable = true;
    environmentFile = "/run/gatus.env";
    settings = {
      web.address = "127.0.0.1"; # localhost only — Traefik proxies externally
      web.port = 8080; # Gatus default — explicit so the port is easy to find
      alerting.custom = {
        url = "$NTFY_URL";
        method = "POST";
        headers = {
          "Content-Type" = "text/plain";
          "Title" = "Homelab / Gatus";
          "Tags" = "warning";
          "Priority" = "high";
        };
        body = "[ALERT_TRIGGERED_OR_RESOLVED]: [ENDPOINT_NAME] — [ALERT_DESCRIPTION]";
        "default-alert" = {
          "failure-threshold" = 3;
          "success-threshold" = 1;
          "send-on-resolved" = true;
        };
      };
      endpoints = [
        {
          name = "Backup / beszel-hub";
          url = "http://127.0.0.1:${toString shimPort}/";
          interval = "1h";
          conditions = [ "[STATUS] == 200" ];
          alerts = [
            {
              type = "custom";
              description = "backup stale or missing (>25h)";
            }
          ];
        }
        {
          name = "Backup / adguard-home";
          url = "http://127.0.0.1:${toString config.services.backup-healthcheck.checks.adguard.port}/";
          interval = "1h";
          conditions = [ "[STATUS] == 200" ];
          alerts = [
            {
              type = "custom";
              description = "backup stale or missing (>25h)";
            }
          ];
        }
        {
          name = "Backup / fusion";
          url = "http://127.0.0.1:${toString config.services.backup-healthcheck.checks.fusion.port}/";
          interval = "1h";
          conditions = [ "[STATUS] == 200" ];
          alerts = [
            {
              type = "custom";
              description = "backup stale or missing (>25h)";
            }
          ];
        }
        {
          name = "Services / AdGuard";
          url = "http://127.0.0.1:${toString config.services.adguard-home.httpPort}/";
          interval = "5m";
          # Any non-5xx response means AdGuard is alive — / redirects (302) and all
          # endpoints require auth (401), but either proves the service is running.
          conditions = [ "[STATUS] < 500" ];
          alerts = [
            {
              type = "custom";
              description = "AdGuard Home web UI unreachable — DNS likely down";
            }
          ];
        }
        {
          name = "Services / Fusion";
          url = "http://127.0.0.1:${toString config.services.fusion.port}/";
          interval = "5m";
          # Unauthenticated / returns the login page (200) — any non-5xx proves
          # the service is up.
          conditions = [ "[STATUS] < 500" ];
          alerts = [
            {
              type = "custom";
              description = "Fusion unreachable — RSS sync stopped";
            }
          ];
        }
        {
          name = "Services / Kula pi-1";
          url = "http://127.0.0.1:${toString config.services.kula.port}/health";
          interval = "5m";
          conditions = [ "[STATUS] == 200" ];
          alerts = [
            {
              type = "custom";
              description = "Kula unreachable on pi-1 — host metrics stopped";
            }
          ];
        }
        # No check for pi-2/pi-3 kula: those hosts are powered down on purpose,
        # so an endpoint check would alert on an intended state. Their dashboards
        # are simply unreachable while off.
      ];
    };
  };
}
