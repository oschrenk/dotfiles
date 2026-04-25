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
    after = [ "gatus-env.service" "backup-healthcheck-beszel.socket" "backup-healthcheck-adguard.socket" ];
    requires = [ "gatus-env.service" ];
  };

  services.gatus = {
    enable = true;
    environmentFile = "/run/gatus.env";
    settings = {
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
          alerts = [{ type = "custom"; description = "backup stale or missing (>25h)"; }];
        }
        {
          name = "Backup / adguard-home";
          url = "http://127.0.0.1:${toString config.services.backup-healthcheck.checks.adguard.port}/";
          interval = "1h";
          conditions = [ "[STATUS] == 200" ];
          alerts = [{ type = "custom"; description = "backup stale or missing (>25h)"; }];
        }
        {
          name = "Services / AdGuard";
          url = "http://127.0.0.1:${toString config.services.adguard-home.httpPort}/";
          interval = "5m";
          conditions = [ "[STATUS] == 200" ];
          alerts = [{ type = "custom"; description = "AdGuard Home web UI unreachable — DNS likely down"; }];
        }
      ];
    };
  };
}
