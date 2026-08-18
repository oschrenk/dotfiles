{ config, pkgs, ... }:
let
  domain = config.my.domain.homelab.name;

  assets = pkgs.runCommand "glance-assets" { } ''
    mkdir -p $out
    echo ':root { font-size: 11px; }' > $out/custom.css
  '';
  opnixUnit = "opnix-secrets.service";
in
{
  systemd.services.glance-env = {
    description = "Write Glance environment file from opnix secrets";
    before = [ "glance.service" ];
    after = [ opnixUnit ];
    requires = [ opnixUnit ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "glance-env" ''
        echo "WAQI_TOKEN=$(cat /var/lib/opnix/secrets/waqiToken)" > /run/glance.env
        chmod 600 /run/glance.env
      '';
    };
  };

  systemd.services.glance = {
    after = [ "glance-env.service" ];
    requires = [ "glance-env.service" ];
  };

  services.glance = {
    enable = true;
    environmentFile = "/run/glance.env";
    # Traefik fronts this; the service binds localhost only.
    openFirewall = false;
    settings = {
      server = {
        host = "127.0.0.1";
        # The module defaults to 8080, which gatus already uses.
        port = 8082;
        assets-path = "${assets}";
      };

      branding.hide-footer = true;

      theme.custom-css-file = "/assets/custom.css";

      # Glance has no prefers-color-scheme support, so there is no "follow system".
      # Dark is the built-in default; this preset adds a light option to the theme
      # picker, which each browser remembers separately.
      theme.presets.light = {
        light = true;
        background-color = "0 0 95";
        primary-color = "0 0 10";
        negative-color = "0 90 50";
      };

      pages = [
        {
          name = "Home";
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "clock";
                  hour-format = "24h";
                  timezones = [
                    {
                      timezone = "America/Guatemala";
                      label = "Guatemala";
                    }
                    {
                      timezone = "Europe/Amsterdam";
                      label = "Amsterdam";
                    }
                    {
                      timezone = "Europe/Berlin";
                      label = "Düsseldorf";
                    }
                    {
                      timezone = "Asia/Ho_Chi_Minh";
                      label = "Ho Chi Minh";
                    }
                  ];
                }
                {
                  type = "calendar";
                  first-day-of-week = "monday";
                }
              ];
            }
            {
              size = "full";
              widgets = [
                {
                  type = "bookmarks";
                  groups = [
                    {
                      title = "Homelab";
                      links = [
                        {
                          title = "AdGuard Home";
                          url = "https://adguard.${domain}";
                        }
                        {
                          title = "Beszel";
                          url = "https://beszel.${domain}";
                        }
                        {
                          title = "Fusion";
                          url = "https://fusion.${domain}";
                        }
                        {
                          title = "Gatus";
                          url = "https://gatus.${domain}";
                        }
                        {
                          title = "Kula pi-1";
                          url = "https://kula-pi-1.${domain}";
                        }
                        {
                          title = "Kula pi-2";
                          url = "https://kula-pi-2.${domain}";
                        }
                        {
                          title = "Kula pi-3";
                          url = "https://kula-pi-3.${domain}";
                        }
                        {
                          title = "UniFi";
                          url = "https://unifi.${domain}";
                        }
                      ];
                    }
                  ];
                }
              ];
            }
            {
              size = "small";
              widgets = [
                {
                  type = "weather";
                  location = "Guatemala City, Guatemala";
                  units = "metric";
                  hour-format = "24h";
                }
                {
                  type = "custom-api";
                  title = "Air Quality";
                  cache = "15m";
                  url = "https://api.waqi.info/feed/A518311/?token=\${WAQI_TOKEN}";
                  template = ''
                    {{ $aqi := .JSON.Int "data.aqi" }}
                    {{ $pm25 := .JSON.String "data.iaqi.pm25.v" }}
                    {{ $pm10 := .JSON.String "data.iaqi.pm10.v" }}
                    {{ $pm1 := .JSON.String "data.iaqi.pm1.v" }}
                    {{ $updated := .JSON.String "data.time.s" }}

                    <div class="size-h5">
                      {{ if le $aqi 50 }}
                        <div class="color-positive">Good air quality</div>
                      {{ else if le $aqi 100 }}
                        <div class="color-primary">Moderate air quality</div>
                      {{ else }}
                        <div class="color-negative">Bad air quality</div>
                      {{ end }}
                    </div>

                    <div class="color-highlight size-h2">AQI: {{ $aqi }}</div>
                    <div style="border-bottom: 1px solid; margin-block: 10px;"></div>

                    <div class="margin-block-2">
                      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
                        <div>
                          <div class="size-h3 color-highlight">{{ $pm25 }}</div>
                          <div class="size-h6">PM2.5</div>
                        </div>
                        <div>
                          <div class="size-h3 color-highlight">{{ $pm10 }}</div>
                          <div class="size-h6">PM10</div>
                        </div>
                        <div>
                          <div class="size-h3 color-highlight">{{ $pm1 }}</div>
                          <div class="size-h6">PM1</div>
                        </div>
                      </div>
                      <div class="size-h6" style="margin-top: 10px;">CINCOHILOS, Zone 14 &middot; {{ slice $updated 11 16 }}</div>
                    </div>
                  '';
                }
              ];
            }
          ];
        }
      ];
    };
  };
}
