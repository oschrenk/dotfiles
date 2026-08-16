{ config, ... }:
let
  domain = config.my.domain.homelab.name;
in
{
  services.glance = {
    enable = true;
    # Traefik fronts this; the service binds localhost only.
    openFirewall = false;
    settings = {
      server = {
        host = "127.0.0.1";
        # The module defaults to 8080, which gatus already uses.
        port = 8082;
      };

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
                          title = "Beszel";
                          url = "https://beszel.${domain}";
                        }
                        {
                          title = "Gatus";
                          url = "https://gatus.${domain}";
                        }
                        {
                          title = "AdGuard Home";
                          url = "https://adguard.${domain}";
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
              ];
            }
          ];
        }
      ];
    };
  };
}
