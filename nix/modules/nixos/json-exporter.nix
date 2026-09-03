{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.jsonExporter;
in
{
  options.my.jsonExporter = {
    port = lib.mkOption {
      type = lib.types.port;
      default = 7979;
      description = "Port json_exporter listens on, loopback only — Prometheus scrapes it over that.";
    };

    modules = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf (lib.types.attrsOf lib.types.anything));
      default = { };
      description = ''
        json_exporter modules, keyed by the name a scrape selects with ?module=.
        Each value is that module's metrics list.

        nixpkgs exposes one json_exporter per host, so a module that wants JSON
        metrics contributes here rather than setting
        services.prometheus.exporters.json itself — two files binding configFile
        would conflict. One process serving many modules is json_exporter's own
        design; the scrape picks which one answers.
      '';
    };
  };

  config = lib.mkIf (cfg.modules != { }) {
    services.prometheus.exporters.json = {
      enable = true;
      inherit (cfg) port;
      # Loopback only: Prometheus runs on this host and scrapes over it, same as
      # unpoller. Nothing outside the box has any business asking for this.
      listenAddress = "127.0.0.1";
      configFile = (pkgs.formats.yaml { }).generate "json-exporter.yml" {
        modules = lib.mapAttrs (_: metrics: { inherit metrics; }) cfg.modules;
      };
    };
  };
}
