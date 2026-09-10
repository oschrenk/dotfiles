{ config, lib, pkgs, ... }:
let
  cfg = config.services.homelab;
  domain = config.my.domain.homelab.name;

  entrypointHttp = "web";
  entrypointHttps = "websecure";
  certResolver = "letsencrypt";
  acmeStorage = "/var/lib/traefik/acme.json";
  envFile = "/run/traefik.env";
  opnixUnit = "opnix-secrets.service";

  # One wildcard for every route, so Certificate Transparency logs don't
  # enumerate the services.
  tls = {
    inherit certResolver;
    domains = [
      {
        main = domain;
        sans = [ "*.${domain}" ];
      }
    ];
  };

  mkRouter = name: {
    rule = "Host(`${name}.${domain}`)";
    service = name;
    entryPoints = [ entrypointHttps ];
    inherit tls;
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
      environmentFiles = [ envFile ];
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
          dnsChallenge = {
            provider = "cloudflare";
            # Public resolvers, not the host's: AdGuard rewrites *.${domain}
            # to a tailnet address, which would break lego's propagation check.
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
            inherit tls;
          };
        }
        // builtins.listToAttrs (
          map (r: {
            name = r.name;
            value = mkRouter r.name;
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
      wants = [ opnixUnit ];
      serviceConfig = {
        Type = "oneshot";
        Restart = "on-failure";
        RestartSec = 30;
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "traefik-env" ''
          echo "CLOUDFLARE_DNS_API_TOKEN=$(cat /var/lib/opnix/secrets/cloudflareDnsToken)" > ${envFile}
          chmod 600 ${envFile}
        '';
      };
    };

    systemd.services.traefik = {
      after = [
        opnixUnit
        "traefik-env.service"
      ];
      # traefik-env stays a hard requirement, since it writes the env file
      # traefik reads. opnix is only wanted, so a boot with no WAN still starts
      # traefik from the cached secret.
      wants = [ opnixUnit ];
      requires = [ "traefik-env.service" ];
      # The upstream module's StartLimitIntervalSec=1d with the default 100ms
      # RestartSec lets five failures land inside half a second, and traefik
      # then stays dead for a day. Retry forever instead, backing off to two
      # minutes. mkForce because the upstream module sets the interval itself.
      unitConfig.StartLimitIntervalSec = lib.mkForce 0;
      serviceConfig = {
        RestartSec = 5;
        RestartSteps = 5;
        RestartMaxDelaySec = "2min";
      };
    };

    # tailscale0 is a trustedInterface (base.nix), so Tailscale traffic reaches
    # traefik without any firewall opening here. This module opens no LAN port:
    # only a tailnet peer reaches the apex and its routes. DNS (53) belongs to
    # adguard.nix and SSH (22) to services.openssh.
  };
}
