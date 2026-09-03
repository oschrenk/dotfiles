{
  config,
  ...
}:
let
  # Zona 14, from the OpenStreetMap boundary relation for the quarter
  # (14.5835631, -90.5137158). Open-Meteo snaps to its nearest grid cell at
  # 14.587 / -90.5014, elevation 1503 m — ~1.4 km away and still inside the
  # zone's own bounding box, so this is Zona 14 weather rather than a city
  # average taken from the airport.
  latitude = "14.5836";
  longitude = "-90.5137";

  # No key and no secret to add, unlike the WAQI feed glance.nix uses.
  #
  # timeformat=unixtime with timezone=GMT so any timestamp read out of this
  # response is already epoch seconds; the ISO default would need parsing.
  target =
    "https://api.open-meteo.com/v1/forecast"
    + "?latitude=${latitude}&longitude=${longitude}"
    + "&current=temperature_2m,apparent_temperature,relative_humidity_2m"
    + "&timeformat=unixtime&timezone=GMT";

  # One label, carried by all three metrics: this is where the reading is from,
  # and it is what the Perses panels use as the series name.
  location = "Guatemala City Zona 14";
in
{
  config = {
    # The exporter itself lives in modules/nixos/json-exporter.nix, which several
    # modules feed. Only the weather module and its scrape job are stated here.
    my.jsonExporter.modules.weather = [
      {
        name = "weather_temperature_celsius";
        type = "value";
        help = "Outside air temperature two metres above ground";
        path = "{ .current.temperature_2m }";
        labels = { inherit location; };
      }
      # What it feels like: temperature after humidity, wind and radiation. In a
      # city at 1500 m with 90% afternoon humidity the two diverge by several
      # degrees, which is the half that explains the room.
      {
        name = "weather_apparent_temperature_celsius";
        type = "value";
        help = "Perceived temperature, combining humidity, wind and radiation";
        path = "{ .current.apparent_temperature }";
        labels = { inherit location; };
      }
      {
        name = "weather_relative_humidity_percent";
        type = "value";
        help = "Outside relative humidity two metres above ground";
        path = "{ .current.relative_humidity_2m }";
        labels = { inherit location; };
      }
    ];

    services.prometheus.scrapeConfigs = [
      {
        job_name = "weather";

        # Probe-style, same shape as the fx job: the URL to fetch arrives as
        # ?target=, so the target below is the *upstream* and the relabeling
        # rewrites __address__ to the exporter. Without the last rule Prometheus
        # would scrape api.open-meteo.com directly and get JSON, not metrics.
        metrics_path = "/probe";
        params.module = [ "weather" ];
        static_configs = [ { targets = [ target ]; } ];

        # Upstream refreshes every 15 minutes and says so in current.interval,
        # but 15m here would put every sample outside Prometheus' 5m lookback
        # and draw a dotted line, the way fx_rate needs last_over_time to be
        # graphable at all. 5m keeps the series continuous at 288 requests a
        # day, far under Open-Meteo's free non-commercial allowance, and the
        # repeated values compress to almost nothing.
        scrape_interval = "5m";

        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            target_label = "__address__";
            replacement = "127.0.0.1:${toString config.my.jsonExporter.port}";
          }
        ];

        # The weather is a fact about the world, not a property of the pi that
        # happened to fetch it. Same reasoning as fx: Open-Meteo has a historical
        # archive API, so a later backfill has to be able to write series with
        # labels identical to these. Safe because exactly one target produces
        # these metrics.
        #
        # `up` is synthetic and keeps its own labels, so up{job="weather"} still
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
