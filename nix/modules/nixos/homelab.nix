{ config, lib, ... }:
let
  cfg = config.services.homelab;
  domain = config.my.domain.homelab.name;

  entrypointHttp = "web";
  entrypointHttps = "websecure";
  certResolver = "internal";
  acmeStorage = "/var/lib/traefik/acme.json";
  # 'localhost' not '127.0.0.1': Go TLS requires a DNS SAN; step-ca has 'localhost' but no IP SAN.
  caUrl = "https://localhost:${toString config.services.homelab-ca.port}/acme/acme/directory";

  mkRouter = name: {
    rule = "Host(`${name}.${domain}`)";
    service = name;
    entryPoints = [ entrypointHttps ];
    tls.certResolver = certResolver;
  };

  # Upstreams presenting a self-signed cert (unifi) go through this transport.
  insecureTransport = "insecure";

  mkService = r: {
    loadBalancer = {
      servers = [ { url = "${r.scheme}://${r.host}:${toString r.port}"; } ];
    } // lib.optionalAttrs r.insecureTls { serversTransport = insecureTransport; };
  };

  mkLocalService = port: mkService {
    scheme = "http";
    host = "127.0.0.1";
    inherit port;
    insecureTls = false;
  };
in
{
  options.services.homelab = {
    homepagePort = lib.mkOption {
      type = lib.types.port;
      default = 8081;
      description = "Port nginx serves the homepage on (localhost only).";
    };
    routes = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption { type = lib.types.str; };
            port = lib.mkOption { type = lib.types.port; };
            host = lib.mkOption {
              type = lib.types.str;
              default = "127.0.0.1";
              description = "Upstream address. Override for services on another machine.";
            };
            scheme = lib.mkOption {
              type = lib.types.enum [ "http" "https" ];
              default = "http";
              description = "Protocol Traefik uses to reach the upstream.";
            };
            insecureTls = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Skip upstream certificate verification (self-signed backends).";
            };
          };
        }
      );
      default = [ ];
      description = "Services to expose via Traefik.";
    };
  };

  config = {
    services.traefik = {
      enable = true;
      staticConfigOptions = {
        entryPoints.${entrypointHttp} = {
          address = ":80";
          http.redirections.entryPoint = {
            to = entrypointHttps;
            scheme = "https";
          };
        };
        entryPoints.${entrypointHttps}.address = ":443";
        certificatesResolvers.${certResolver}.acme = {
          email = config.my.personal.email;
          storage = acmeStorage;
          caServer = caUrl;
          httpChallenge.entryPoint = entrypointHttp;
        };
        # api omitted — dashboard is off by default
      };
      dynamicConfigOptions.http = {
        routers = {
          homepage = {
            rule = "Host(`${domain}`)";
            service = "homepage";
            entryPoints = [ entrypointHttps ];
            tls.certResolver = certResolver;
          };
        }
        // builtins.listToAttrs (
          map (r: {
            name = r.name;
            value = mkRouter r.name;
          }) cfg.routes
        );
        services = {
          homepage = mkLocalService cfg.homepagePort;
        }
        // builtins.listToAttrs (
          map (r: {
            name = r.name;
            value = mkService r;
          }) cfg.routes
        );
        serversTransports.${insecureTransport}.insecureSkipVerify = true;
      };
    };

    # Trust step-ca's TLS cert when lego connects to the internal ACME endpoint.
    systemd.services.traefik = {
      after = [ "opnix-secrets.service" ];
      requires = [ "opnix-secrets.service" ];
      environment.LEGO_CA_CERTIFICATES = "/run/step-ca-root.crt";
    };

    # tailscale0 is a trustedInterface (base.nix), so Tailscale traffic bypasses
    # the firewall entirely. For LAN clients we open 443 explicitly. Port 80 is
    # intentionally NOT in allowedTCPPorts — clients on LAN must use https://.
    networking.firewall.allowedTCPPorts = [ 443 ];
  };
}
