{ config, ... }:
let
  domain = config.my.domain.homelab.name;
  host = config.my.host.${config.my.domain.homelab.hostName};
  subdomains = config.my.domain.homelab.subdomains;
in
{
  # subdomains (hosts/network.nix) is what the Macs pin in /etc/hosts, so a route
  # missing from it would resolve here but nowhere else.
  assertions = [
    {
      assertion = builtins.all (r: builtins.elem r.name subdomains) config.services.homelab.routes;
      message = "every services.homelab.routes name must appear in my.domain.homelab.subdomains";
    }
  ];

  # The apex (${domain} with no subdomain) serves Glance.
  services.homelab.apexPort = config.services.glance.settings.server.port;

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
    {
      name = "fusion";
      port = config.services.fusion.port;
    }
    # UniFi runs on pi-3, not here, and serves its own self-signed cert on 8443.
    {
      name = "unifi";
      host = config.my.host."pi-3".lanIp;
      port = 8443;
      scheme = "https";
      insecureTls = true;
    }
  ];

  # Answers with the tailnet address so the name resolves the same at home and
  # on cellular. Two entries are required: AdGuard's adblock-style `||domain^`
  # rule does not match the apex, so use dns.rewrites with explicit apex +
  # wildcard.
  services.adguardhome.settings.dns.rewrites = [
    { domain = domain; answer = host.tailscaleIp; }
    { domain = "*.${domain}"; answer = host.tailscaleIp; }
  ];

  # AdGuard Home reads /etc/hosts before applying dns.rewrites, so this must
  # match the rewrite IP — otherwise AdGuard returns this entry and the rewrite
  # never fires for the apex / listed subdomains.
  networking.hosts.${host.tailscaleIp} =
    [ domain ] ++ map (s: "${s}.${domain}") subdomains;
}
