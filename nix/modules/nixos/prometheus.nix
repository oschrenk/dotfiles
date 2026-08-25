{
  config,
  lib,
  pkgs,
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

  elec = config.my.electricity;
  currency = lib.toLower elec.currency;

  # 24 h x 30.4375 d is the mean calendar month; /1000 takes watts to kWh. Using
  # 30 would understate every month by 1.5%, which is more than the precision the
  # tariff itself is quoted to.
  kWhPerWattMonth = 24.0 * 30.4375 / 1000.0;

  # The band. Low takes the switch's reported figure at face value on the cheapest
  # tier; high assumes the top tier and that the port understates wall draw by the
  # PSU and cable loss the switch cannot see. nix renders these to six decimals.
  costFactorLow = kWhPerWattMonth * elec.pricePerKwhLow;
  costFactorHigh = kWhPerWattMonth * elec.conversionLossFactor * elec.pricePerKwhHigh;
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

      # The tariff arithmetic lives here rather than in the Perses panel because
      # homelab.cue is built by `task homelab:perses-dashboards` outside the nix
      # evaluation and cannot read config.my.electricity. Recording rules are the
      # one seam where a nix option legitimately becomes a Prometheus series, and
      # they leave the rate stated exactly once in the repo.
      #
      # These are also backfillable: `promtool tsdb create-blocks-from rules`
      # recomputes them over PoE history that predates the rule landing. See the
      # homelab:prometheus-cost-backfill task.
      rules = [
        ''
          groups:
            - name: poe-cost
              # Matches globalConfig.scrape_interval. A rule evaluated more often
              # than its input is sampled just repeats itself.
              interval: 60s
              rules:
                - record: homelab:poe_watts:total
                  expr: sum(unpoller_device_port_poe_watts)

                - record: homelab:poe_cost_${currency}_per_month:low
                  expr: sum(unpoller_device_port_poe_watts) * ${toString costFactorLow}

                - record: homelab:poe_cost_${currency}_per_month:high
                  expr: sum(unpoller_device_port_poe_watts) * ${toString costFactorHigh}

                # Upper factor rather than an invented midpoint, so these series
                # sum to :high exactly and the panel can be checked against it.
                #
                # The parentheses are load-bearing: `*` binds tighter than `>`, so
                # `watts > 0 * f` filters against zero and returns raw watts. The
                # rule would evaluate, record, and graph a plausible-looking number
                # in the wrong unit.
                - record: homelab:poe_cost_${currency}_per_month:by_port
                  expr: (unpoller_device_port_poe_watts > 0) * ${toString costFactorHigh}
        ''
      ];
    };

    # promtool ships in the package's `cli` output, not the default one — the main
    # output has only `prometheus` and `migrate`. Taking it from the same pkgs as the
    # server keeps the two versions in step, which matters because it writes blocks
    # straight into the running TSDB. Used by scripts/prometheus-cost-backfill.sh.
    environment.systemPackages = [ pkgs.prometheus.cli ];

    # Backed up by restic on this host; see modules/nixos/restic/. The directory
    # is the single path that needs it — Perses is reproducible from definitions.
    systemd.services.prometheus.serviceConfig.StateDirectory = lib.mkDefault "prometheus2";
  };
}
