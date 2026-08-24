{
  config,
  lib,
  ...
}:
let
  cfg = config.services.prometheus;

  # kula runs on all three pis and already exposes /metrics. Scraped over the
  # tailnet rather than the LAN: base.nix opens no LAN ports and trusts
  # tailscale0, so the tailscale address is the one that answers. Same reasoning
  # as the kula backends in sites/lab.oschrenk.gt.nix.
  kulaTargets = map (host: "${config.my.host.${host}.tailscaleIp}:${toString config.services.kula.port}") [
    "pi-1"
    "pi-2"
    "pi-3"
  ];
in
{
  config = {
    services.prometheus = {
      enable = true;

      # localhost only. Nothing proxies Prometheus itself — Perses is the front
      # end, and it queries over loopback.
      listenAddress = "127.0.0.1";
      port = 9090;

      globalConfig = {
        # 60s, not Prometheus' 15s default. Temperature does not move fast, and
        # 15s is four times the flash writes for no additional signal.
        scrape_interval = "60s";
      };

      # 90d, not the 15d default, so a season change is visible. kula emits 85
      # samples per scrape, so three hosts at 60s is ~33M samples over the window
      # — under 100 MB. Re-check if the series count grows beyond kula.
      retentionTime = "90d";

      scrapeConfigs = [
        {
          job_name = "kula";
          static_configs = [ { targets = kulaTargets; } ];
        }
      ];
    };

    # Backed up by restic on this host; see modules/nixos/restic/. The directory
    # is the single path that needs it — Perses is reproducible from definitions.
    systemd.services.prometheus.serviceConfig.StateDirectory = lib.mkDefault "prometheus2";
  };
}
