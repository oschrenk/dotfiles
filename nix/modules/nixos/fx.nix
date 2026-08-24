{
  config,
  pkgs,
  ...
}:
let
  port = 7979;

  # open.er-api.com needs no key and returns GTQ per EUR directly under
  # .rates.GTQ, so no reciprocal in the query and no second request to invert.
  # Base EUR rather than base GTQ deliberately: base GTQ would give EUR-per-GTQ
  # (0.112), which is the same fact in a form nobody can hold in their head.
  target = "https://open.er-api.com/v6/latest/EUR";

  # The metric identity must match the backfilled history exactly, or the live
  # series and the imported one are two different series that never join. See
  # scripts/fx-backfill.sh.
  configFile = (pkgs.formats.yaml { }).generate "json-exporter.yml" {
    modules.fx.metrics = [
      {
        name = "fx_rate";
        type = "value";
        help = "Units of quote currency per one unit of base currency";
        path = "{ .rates.GTQ }";
        labels = {
          base = "EUR";
          quote = "GTQ";
        };
      }
      # A feed that quietly freezes otherwise looks like a stable currency. This
      # is the source's own timestamp, so staleness is visible as data rather
      # than inferred from a flat line.
      {
        name = "fx_rate_updated_timestamp_seconds";
        type = "value";
        help = "When the upstream provider last refreshed the rate";
        path = "{ .time_last_update_unix }";
        labels = {
          base = "EUR";
          quote = "GTQ";
        };
      }
    ];
  };
in
{
  config = {
    services.prometheus.exporters.json = {
      enable = true;
      inherit port;
      # Loopback only: Prometheus runs on this host and scrapes over it, same as
      # unpoller. Nothing outside the box has any business asking for this.
      listenAddress = "127.0.0.1";
      inherit configFile;
    };

    services.prometheus.scrapeConfigs = [
      {
        job_name = "fx";

        # json_exporter is probe-style: the URL to fetch arrives as ?target=,
        # so the target below is the *upstream* and the relabeling rewrites
        # __address__ to the exporter. Without the last rule Prometheus would
        # try to scrape open.er-api.com directly and get JSON, not metrics.
        metrics_path = "/probe";
        params.module = [ "fx" ];
        static_configs = [ { targets = [ target ]; } ];

        # The rate changes once a day; the provider says so in
        # time_next_update_utc. Hourly is 24 requests a day against a free
        # endpoint rather than 1440, and the panel already reads through
        # last_over_time, so a sparse series costs nothing.
        scrape_interval = "1h";

        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            target_label = "__address__";
            replacement = "127.0.0.1:${toString port}";
          }
        ];

        # An exchange rate is a fact about the world, not a property of the host
        # that happened to fetch it. Dropping job and instance keeps the live
        # series identical to the backfilled one — with them, promtool's
        # fx_rate{base,quote} and the scraped fx_rate{base,quote,job,instance}
        # are separate series and the history simply stops where the backfill
        # ended. Safe because exactly one target produces this metric; two would
        # collide on identical labels.
        #
        # `up` is synthetic and keeps its own labels, so up{job="fx"} still
        # works for alerting.
        metric_relabel_configs = [
          {
            regex = "job|instance";
            action = "labeldrop";
          }
        ];
      }
    ];
  };
}
