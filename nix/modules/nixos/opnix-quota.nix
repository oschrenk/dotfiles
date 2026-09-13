{ pkgs, lib, ... }:
# 1Password has request quotas:
# - 1000 requests per 24h pooled across every service account,
# - above that you will get 429
# - to understand how much we use when polling polling using we graph our usage
#
let
  textfileDir = "/var/lib/opnix-quota";

  # `op service-account ratelimit` reports the token's own budget and costs nothing against it. 
  collect = pkgs.writeShellScript "opnix-quota-collect" ''
    set -euo pipefail
    export OP_SERVICE_ACCOUNT_TOKEN="$(cat "$CREDENTIALS_DIRECTORY/token")"

    out=${textfileDir}/onepassword_ratelimit.prom
    # Not *.prom, so the collector ignores 
    # trap stops a failed run from leaving one behind 
    tmp="$out.$$"
    trap 'rm -f "$tmp"' EXIT

    ${pkgs._1password-cli}/bin/op service-account ratelimit --format json \
      | ${pkgs.jq}/bin/jq -r '
          . as $rows
          | ({"limit":"limit","used":"used","remaining":"remaining","reset":"reset_seconds"}
             | to_entries[]) as $f
          | "# TYPE onepassword_ratelimit_\($f.value) gauge",
            ($rows[] | "onepassword_ratelimit_\($f.value){type=\"\(.type)\",action=\"\(.action)\"} \(.[$f.key])")
        ' > "$tmp"

    mv "$tmp" "$out"
  '';
in
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "1password-cli"
    ];

  users.users.opnix-quota = {
    isSystemUser = true;
    group = "opnix-quota";
  };
  users.groups.opnix-quota = { };

  systemd.services.opnix-quota = {
    description = "Export the 1Password service account request quota";
    after = [
      "network-online.target"
      "nss-lookup.target"
    ];
    wants = [
      "network-online.target"
      "nss-lookup.target"
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = collect;
      User = "opnix-quota";
      Group = "opnix-quota";
      LoadCredential = [ "token:/etc/opnix-token" ];
      # op refuses to start without config directory
      StateDirectory = "opnix-quota";
      Environment = [ "HOME=%S/opnix-quota" ];
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
    };
  };

  systemd.timers.opnix-quota = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "5min";
      Unit = "opnix-quota.service";
    };
  };

  services.prometheus.exporters.node = {
    enabledCollectors = [ "textfile" ];
    extraFlags = [ "--collector.textfile.directory=${textfileDir}" ];
  };
}
