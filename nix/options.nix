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
}
