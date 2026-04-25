{ config, pkgs, lib, ... }:
let
  cfg = config.services.adguard-home;
in
{
  options.services.adguard-home = {
    dnsPort = lib.mkOption {
      type    = lib.types.port;
      default = 53;
    };
    httpPort = lib.mkOption {
      type    = lib.types.port;
      default = 3000;
    };
    # Interfaces AdGuard binds DNS on. Defaults to all interfaces (0.0.0.0).
    # Set to specific IPs (e.g. LAN + tailscale) to avoid conflicting with
    # systemd-resolved's stub listener on 127.0.0.53:53, which lets resolved
    # keep handling the host's own DNS while AdGuard serves LAN clients.
    bindHosts = lib.mkOption {
      type    = lib.types.listOf lib.types.str;
      default = [ "0.0.0.0" ];
      description = "List of IPs AdGuard binds DNS on.";
    };
  };

  config = {
    # mutableSettings = false: Nix is the single source of truth for all AdGuard Home
    # configuration. On every nixos-rebuild, AdGuardHome.yaml is overwritten from this
    # file. This means:
    #
    #   - Changes made in the web UI are intentionally wiped on next rebuild.
    #   - All config (filters, DNS rewrites, client settings, custom rules, retention
    #     periods) must live here, not in the UI.
    #   - Workflow: edit this file → rebuild → UI reflects the change.
    #
    # The full AdGuard Home settings surface maps 1:1 to AdGuardHome.yaml via settings.*:
    #   settings.dns.rewrites         — local hostname → IP (needed for Traefik later)
    #   settings.user_rules           — per-domain allow/block overrides
    #   settings.clients.persistent   — named clients with per-client settings
    #   settings.querylog.interval    — query log retention period
    #   settings.statistics.interval  — stats retention period
    #
    # Collected data (query logs, stats) lives in data/ and is NEVER touched by
    # mutableSettings — only AdGuardHome.yaml is overwritten.
    services.adguardhome = {
      enable          = true;
      mutableSettings = false;
      settings = {
        http.address = "127.0.0.1:${toString cfg.httpPort}"; # localhost only — Traefik proxies externally
        # Trust Traefik's X-Forwarded-For headers so AdGuard sees real client IPs.
        trusted_proxies = [ "127.0.0.1" "::1" ];
        dns = {
          bind_hosts    = cfg.bindHosts;
          anonymize_client_ip = false;
          port          = cfg.dnsPort;
          # Quad9 used as bootstrap to resolve the DoH upstream hostname itself.
          bootstrap_dns = [ "9.9.9.9" "149.112.112.112" ];
          upstream_dns  = [ "https://dns.quad9.net/dns-query" ];
        };
        filters_update_interval = 24;  # hours; AdGuard refreshes lists automatically

        # id fields must be stable integers — AdGuard Home uses them as persistent
        # filter identifiers. Never reuse an id even if a filter is removed; just
        # delete the entry and leave a gap in the sequence.
        #
        # Note: the N in HostlistsRegistry/assets/filter_N.txt is AdGuard's internal
        # registry numbering, unrelated to the id values we assign here.
        #
        # To browse available lists:
        #   https://github.com/AdguardTeam/HostlistsRegistry  — AdGuard-curated registry
        #   https://github.com/hagezi/dns-blocklists          — HaGeZi lists (more aggressive)
        #   https://oisd.nl                                   — OISD list info
        filters = [
          # Conservative, well-maintained. Good baseline with very few false positives.
          { id = 1; enabled = true; name = "AdGuard DNS filter";
            url = "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt"; }
          # Excellent curation, extremely low false positive rate. Covers most trackers.
          { id = 2; enabled = true; name = "OISD Basic";
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt"; }
          # Mobile-specific ad networks. Conservative enough to include from the start.
          { id = 3; enabled = true; name = "AdGuard Mobile Ads";
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_4.txt"; }
          # HaGeZi Pro and EasyPrivacy omitted — more aggressive, can cause false
          # positives on banking sites and CDNs. Add as id 4 and 5 after validating
          # no breakage on your network.
        ];

        querylog = {
          # "168h" = 7 days. Go's time.ParseDuration has no "d" unit — largest is "h".
          interval = "168h";
        };

        # Both username and password come from opnix at service start — neither is
        # hardcoded here. Placeholders are replaced by the ExecStartPre script below.
        # Reason: opnix secrets are only available at runtime, not at Nix eval time,
        # so they cannot be embedded in the Nix store.
        users = [{ name = "ADGUARD_USERNAME_PLACEHOLDER"; password = "ADGUARD_PASSWORD_PLACEHOLDER"; }];
      };
    };

    # The NixOS adguardhome module writes AdGuardHome.yaml in its own preStart
    # (first ExecStartPre). Our script runs as a second ExecStartPre after that,
    # patching in the credentials from opnix secrets.
    #
    # awk -v passes values without shell re-expansion; gsub replacement does not
    # treat '$' as special, so bcrypt hashes (e.g. $2b$10$...) pass through intact.
    # sed would mangle them. Python would pull in an unnecessary runtime dependency.
    systemd.services.adguardhome = {
      after    = [ "opnix-secrets.service" ];
      requires = [ "opnix-secrets.service" ];
      # '+' prefix: run this script as root regardless of the service user.
      # Required because opnix secrets are owner=root mode=0600 — the adguardhome
      # service user cannot read them without privilege escalation.
      serviceConfig.ExecStartPre = "+" + pkgs.writeShellScript "adguardhome-inject-credentials" ''
        USERNAME=$(cat /var/lib/opnix/secrets/adguardUsername)
        HASH=$(cat /var/lib/opnix/secrets/adguardPasswordHash)
        ${pkgs.gawk}/bin/awk -v user="$USERNAME" -v hash="$HASH" \
          '{gsub(/ADGUARD_USERNAME_PLACEHOLDER/, user);
            gsub(/ADGUARD_PASSWORD_PLACEHOLDER/, hash); print}' \
          /var/lib/AdGuardHome/AdGuardHome.yaml \
          > /tmp/adguardhome.yaml
        mv /tmp/adguardhome.yaml /var/lib/AdGuardHome/AdGuardHome.yaml
      '';
    };

    # DNS: open 53 on all interfaces — LAN clients need to reach it.
    # Web UI: no explicit rule needed — tailscale0 is a trustedInterface (base.nix)
    # so all ports are implicitly reachable over Tailscale without an explicit rule.
    networking.firewall.allowedUDPPorts = [ cfg.dnsPort ];
    networking.firewall.allowedTCPPorts = [ cfg.dnsPort ];
  };
}
