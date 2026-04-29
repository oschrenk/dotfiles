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
    name = lib.mkOption { type = lib.types.str; };
    hostName = lib.mkOption { type = lib.types.str; };
  };
}
