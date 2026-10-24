{ lib, ... }:
{
  options.my.host = {
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
