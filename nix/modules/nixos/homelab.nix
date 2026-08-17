{ config, lib, pkgs, ... }:
let
  cfg = config.services.homelab;
  domain = config.my.domain.homelab.name;
  publicDomain = config.my.domain.homelab.publicName;

  entrypointHttp = "web";
  entrypointHttps = "websecure";
  certResolver = "internal";
  publicCertResolver = "letsencrypt";
  acmeStorage = "/var/lib/traefik/acme.json";
  envFile = "/run/traefik.env";
  opnixUnit = "opnix-secrets.service";
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

  publicTls = {
    certResolver = publicCertResolver;
    domains = [
      {
        main = publicDomain;
        sans = [ "*.${publicDomain}" ];
      }
    ];
  };

  mkPublicRouter = name: {
    rule = "Host(`${name}.${publicDomain}`)";
    service = name;
    entryPoints = [ entrypointHttps ];
    tls = publicTls;
  };
in
{
  options.services.homelab = {
    apexPort = lib.mkOption {
      type = lib.types.port;
      description = ''
        Port the apex host (${domain} with no subdomain) is proxied to, on localhost.
        Required — an unset apex would proxy to a dead port. Set it in the site file.
      '';
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
        certificatesResolvers.${publicCertResolver}.acme = {
          email = config.my.personal.email;
          storage = acmeStorage;
          dnsChallenge = {
            provider = "cloudflare";
            # Public resolvers, not the host's: AdGuard rewrites *.${publicDomain}
            # to a LAN address, which would break lego's propagation check.
            resolvers = [
              "1.1.1.1:53"
              "8.8.8.8:53"
            ];
          };
        };
        # api omitted — dashboard is off by default
      };
      dynamicConfigOptions.http = {
        routers = {
          apex = {
            rule = "Host(`${domain}`)";
            service = "apex";
            entryPoints = [ entrypointHttps ];
            tls.certResolver = certResolver;
          };
          apex-public = {
            rule = "Host(`${publicDomain}`)";
            service = "apex";
            entryPoints = [ entrypointHttps ];
            tls = publicTls;
          };
        }
        // builtins.listToAttrs (
          map (r: {
            name = r.name;
            value = mkRouter r.name;
          }) cfg.routes
        )
        // builtins.listToAttrs (
          map (r: {
            name = "${r.name}-public";
            value = mkPublicRouter r.name;
          }) cfg.routes
        );
        services = {
          apex = mkLocalService cfg.apexPort;
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

    systemd.services.traefik-env = {
      description = "Write Traefik environment file from opnix secrets";
      before = [ "traefik.service" ];
      after = [ opnixUnit ];
      requires = [ opnixUnit ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "traefik-env" ''
          echo "CLOUDFLARE_DNS_API_TOKEN=$(cat /var/lib/opnix/secrets/cloudflareDnsToken)" > ${envFile}
          chmod 600 ${envFile}
        '';
      };
    };

    services.traefik.environmentFiles = [ envFile ];

    # Trust step-ca's TLS cert when lego connects to the internal ACME endpoint.
    systemd.services.traefik = {
      after = [
        opnixUnit
        "traefik-env.service"
      ];
      requires = [
        opnixUnit
        "traefik-env.service"
      ];
      environment.LEGO_CA_CERTIFICATES = "/run/step-ca-root.crt";
      # Without this, the step-ca root above REPLACES lego's trust store and it
      # cannot verify Let's Encrypt's own API certificate.
      environment.LEGO_CA_SYSTEM_CERT_POOL = "true";
    };

    # tailscale0 is a trustedInterface (base.nix), so Tailscale traffic bypasses
    # the firewall entirely. For LAN clients we open 443 explicitly. Port 80 is
    # intentionally NOT in allowedTCPPorts — clients on LAN must use https://.
    networking.firewall.allowedTCPPorts = [ 443 ];
  };
}
