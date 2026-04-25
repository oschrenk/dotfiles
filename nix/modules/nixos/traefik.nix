{ config, lib, ... }:
let
  cfg = config.services.homelab-proxy;

  # Port references — pulled from each service's own module options where possible.
  # Gatus settings is a free-form attrset; .web.port is accessible but not a typed option.
  beszelPort  = config.services.beszel.hub.port;          # beszel-hub.nix
  adguardPort = config.services.adguard-home.httpPort;    # adguard-home.nix
  gatusPort   = config.services.gatus.settings.web.port;  # gatus.nix

  mkRouter = name: {
    rule = "Host(`${name}.${cfg.domain}`)";
    service = name;
    entryPoints = [ "web" ];
  };

  mkService = port: {
    loadBalancer.servers = [{ url = "http://127.0.0.1:${toString port}"; }];
  };
in
{
  options.services.homelab-proxy = {
    domain = lib.mkOption {
      type        = lib.types.str;
      description = "Base domain for all homelab services (e.g. pi-1.local).";
    };
    homepagePort = lib.mkOption {
      type        = lib.types.port;
      default     = 8081;
      description = "Port nginx serves the homepage on (localhost only).";
    };
  };

  config.services.traefik = {
    enable = true;
    staticConfigOptions = {
      entryPoints.web.address = ":80";
      # api omitted — dashboard is off by default
    };
    dynamicConfigOptions.http = {
      routers = {
        homepage = { rule = "Host(`${cfg.domain}`)"; service = "homepage"; entryPoints = [ "web" ]; };
        beszel   = mkRouter "beszel";
        gatus    = mkRouter "gatus";
        adguard  = mkRouter "adguard";
      };
      services = {
        homepage = mkService cfg.homepagePort;
        beszel   = mkService beszelPort;
        gatus    = mkService gatusPort;
        adguard  = mkService adguardPort;
      };
    };
  };

  # No firewall rule needed: tailscale0 is a trustedInterface (base.nix).
  # Port 80 intentionally NOT in allowedTCPPorts — keeps it off LAN.
}
