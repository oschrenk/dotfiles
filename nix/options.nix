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

}
