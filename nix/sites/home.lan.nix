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

  # DNS rewrite: LAN clients resolve ${domain} (apex + subdomains) via AdGuard
  # to pi-1's LAN IP. Two entries are required: AdGuard's adblock-style
  # `||domain^` rule does not match the apex, so use the dedicated dns.rewrites
  # field with explicit apex + wildcard.
  services.adguardhome.settings.dns.rewrites = [
    { domain = domain; answer = host.lanIp; }
    { domain = "*.${domain}"; answer = host.lanIp; }
  ];

  # Needed so step-ca can resolve homelab subdomains during HTTP-01 challenge verification.
  # AdGuard Home also reads /etc/hosts before applying dns.rewrites, so this must
  # match the rewrite IP — otherwise AdGuard returns this entry and the rewrite
  # never fires for the apex / listed subdomains.
  networking.hosts.${host.lanIp} = [
    domain
    "beszel.${domain}"
    "gatus.${domain}"
    "adguard.${domain}"
  ];
}
