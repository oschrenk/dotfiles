{ infuse, pkgs, ... }:

# infuse — mixes shared repositories into the filesystem as symlinks. Supplies
# the tasks/ and CLAUDE.md links this repo is full of.
#
# Package only: the upstream flake exposes packages and apps but no home-manager
# module, so there is nothing to import and no config to declare here.
# ~/.config/infuse/config.toml is still written by hand.
{
  home.packages = [ infuse.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
