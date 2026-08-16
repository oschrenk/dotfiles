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
      pages = [
        {
          name = "Home";
          columns = [
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
          ];
        }
      ];
    };
  };
}
