{ lib, ... }:
{
  options.my.personal = {
    username = lib.mkOption { type = lib.types.str; };
    name = lib.mkOption { type = lib.types.str; };
    email = lib.mkOption { type = lib.types.str; };
    timezone = lib.mkOption {
      type = lib.types.str;
      default = "UTC";
    };
    sshKey = lib.mkOption { type = lib.types.str; };

    # Where the working copy lives. The config trees that are edited daily are
    # symlinked out of the nix store into this path, so a rename is a change
    # here plus a rebuild rather than an edit per consumer.
    dotfiles = lib.mkOption {
      type = lib.types.str;
      example = "/Users/oliver/.local/share/dotfiles";
      description = "Absolute path to the dotfiles working copy.";
    };
  };

  options.my.host = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          lanIp = lib.mkOption { type = lib.types.str; };
          tailscaleIp = lib.mkOption { type = lib.types.str; };
          mac = lib.mkOption { type = lib.types.str; };
        };
      }
    );
    default = { };
  };

  options.my.domain.homelab = {
    name = lib.mkOption {
      type = lib.types.str;
      description = ''
        Publicly registered domain serving the homelab, with certificates from
        Let's Encrypt. Resolves to the reverse proxy's Tailscale address, so it
        is reachable only over the tailnet.
      '';
    };
    hostName = lib.mkOption { type = lib.types.str; };
    subdomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Services fronted by the homelab reverse proxy, as <name>.<domain>.";
    };
  };

  # UNAS network-attached storage. Single source of truth for the static
  # LAN address that pins unas.local across all machines (Avahi is unreliable).
  options.my.nas = {
    ip = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.241";
    };
    hostName = lib.mkOption {
      type = lib.types.str;
      default = "unas.local";
    };
  };

  # Electricity tariff, used by the PoE cost recording rules in
  # modules/nixos/prometheus.nix. Quetzales, not euros — the timezone is
  # America/Guatemala and these are EEGSA's published 2026 rates, not a figure
  # copied from a blog.
  #
  # A band rather than a single rate because two things are genuinely unknown:
  # which consumption tier a marginal watt lands in, and how much of the wall
  # draw the switch reports. One number would hide both.
  options.my.electricity = {
    currency = lib.mkOption {
      type = lib.types.str;
      default = "GTQ";
      description = "Currency the tariff is denominated in. Appears in metric names, so changing it alone is not enough.";
    };

    pricePerKwhLow = lib.mkOption {
      type = lib.types.float;
      default = 1.51;
      description = ''
        Lower bound, currency units per kWh. EEGSA non-subsidised rate as
        published by CNEE for 2026. Replace from an actual bill if the marginal
        tier is known — this is the only place the rate appears.
      '';
    };

    pricePerKwhHigh = lib.mkOption {
      type = lib.types.float;
      default = 2.45;
      description = ''
        Upper bound, currency units per kWh. EEGSA top consumption tier (above
        ~500 kWh/month) for 2026.
      '';
    };

    conversionLossFactor = lib.mkOption {
      type = lib.types.float;
      default = 1.15;
      description = ''
        Multiplier from PoE delivered at the port to power drawn at the wall.
        The switch reports PSE output, which excludes its own PSU efficiency and
        cable loss, so against the bill the reported figure is an underestimate.
        Applied to the upper bound only.
      '';
    };
  };
}
