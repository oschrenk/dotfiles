{ infuse, pkgs, ... }:

# infuse — mixes shared repositories into the filesystem as symlinks. Supplies
# the tasks/ and CLAUDE.md links this repo is full of.
#
# Package only: the upstream flake exposes packages and apps but no home-manager
# module, so there is nothing to import and the config is declared here.
let
  tomlFormat = pkgs.formats.toml { };
in
{
  home.packages = [ infuse.packages.${pkgs.stdenv.hostPlatform.system}.default ];

  # Safe as a read-only store symlink: `add`, `dir`, `link` and `status` only read
  # this file. The one writer is `infuse init`, whose whole job is to create the
  # file that this now generates, so it has nothing left to do.
  #
  # `$XDG_DATA_HOME` is expanded by infuse, not by a shell, so it stays literal.
  xdg.configFile."infuse/config.toml".source = tomlFormat.generate "infuse-config.toml" {
    repo.path = "$XDG_DATA_HOME/infuse";
  };
}
