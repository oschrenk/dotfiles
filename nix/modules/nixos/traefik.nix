{ config, lib, ... }:
let
  cfg = config.services.homelab-proxy;

  entrypointHttp  = "web";
  entrypointHttps = "websecure";
  certResolver    = "internal";
  acmeStorage     = "/var/lib/traefik/acme.json";
  # 'localhost' not '127.0.0.1': Go TLS requires a DNS SAN; step-ca has 'localhost' but no IP SAN.
  caUrl           = "https://localhost:${toString config.services.homelab-ca.port}/acme/acme/directory";

  # Port references — pulled from each service's own module options where possible.
  # Gatus settings is a free-form attrset; .web.port is accessible but not a typed option.
  beszelPort  = config.services.beszel.hub.port;          # beszel-hub.nix
  adguardPort = config.services.adguard-home.httpPort;    # adguard-home.nix
  gatusPort   = config.services.gatus.settings.web.port;  # gatus.nix

  mkRouter = name: {
    rule             = "Host(`${name}.${cfg.domain}`)";
    service          = name;
    entryPoints      = [ entrypointHttps ];
    tls.certResolver = certResolver;
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
    localIp = lib.mkOption {
      type        = lib.types.str;
      description = "IP this host resolves to. Used for /etc/hosts entries for ACME HTTP-01.";
    };
  };

  config = {
    services.traefik = {
      enable = true;
      staticConfigOptions = {
        entryPoints.${entrypointHttp} = {
          address = ":80";
          http.redirections.entryPoint = {
            to     = entrypointHttps;
            scheme = "https";
          };
        };
        entryPoints.${entrypointHttps}.address = ":443";
        certificatesResolvers.${certResolver}.acme = {
          email         = config.my.personal.email;
          storage       = acmeStorage;
          caServer      = caUrl;
          httpChallenge.entryPoint = entrypointHttp;
        };
        # api omitted — dashboard is off by default
      };
      dynamicConfigOptions.http = {
        routers = {
          homepage = {
            rule             = "Host(`${cfg.domain}`)";
            service          = "homepage";
            entryPoints      = [ entrypointHttps ];
            tls.certResolver = certResolver;
          };
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

    # Trust step-ca's TLS cert when lego connects to the internal ACME endpoint.
    systemd.services.traefik = {
      after    = [ "opnix-secrets.service" ];
      requires = [ "opnix-secrets.service" ];
      environment.LEGO_CA_CERTIFICATES = "/run/step-ca-root.crt";
    };

    # Needed so step-ca can resolve homelab subdomains during HTTP-01 challenge verification.
    # Generated here (not pi-1.nix) so adding a new service to traefik gets the entry for free.
    networking.hosts.${cfg.localIp} = [
      cfg.domain
      "beszel.${cfg.domain}"
      "gatus.${cfg.domain}"
      "adguard.${cfg.domain}"
    ];
  };

  # No firewall rule needed: tailscale0 is a trustedInterface (base.nix).
  # Port 80 intentionally NOT in allowedTCPPorts — keeps it off LAN.
}
