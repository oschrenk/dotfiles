{ config, ... }:
let
  domain = config.my.domain.homelab.name;
  host = config.my.host.${config.my.domain.homelab.hostName};
in
{
  services.homelab.routes = [
    {
      name = "beszel";
      port = config.services.beszel.hub.port;
    }
    {
      name = "adguard";
      port = config.services.adguard-home.httpPort;
    }
    {
      name = "gatus";
      port = config.services.gatus.settings.web.port;
    }
  ];

  # DNS rewrite: Tailscale clients resolve *.${domain} via AdGuard.
  services.adguardhome.settings.user_rules = [
    "||${domain}^$dnsrewrite=NOERROR;A;${host.tailscaleIp}"
  ];

  # Needed so step-ca can resolve homelab subdomains during HTTP-01 challenge verification.
  networking.hosts.${host.tailscaleIp} = [
    domain
    "beszel.${domain}"
    "gatus.${domain}"
    "adguard.${domain}"
  ];
}
