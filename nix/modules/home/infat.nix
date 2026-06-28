# infat: declarative macOS default-app associations (user scope).
#
# Was a Homebrew package (gui.nix) plus a chezmoi-managed config. Home Manager
# now owns the binary, the config at ~/.config/infat/config.toml, and applies
# the associations on every switch.
{
  pkgs,
  lib,
  config,
  ...
}:
{
  home.packages = [ pkgs.infat ];

  xdg.configFile."infat/config.toml".source = ./infat/config.toml;

  # infat only writes Launch Services associations when run against the config;
  # placing the file alone does nothing. Apply after HM has written the file.
  # --robust so a missing target app (e.g. an uninstalled cask) does not fail
  # the whole activation.
  home.activation.infatApply = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.infat}/bin/infat -c ${config.xdg.configFile."infat/config.toml".source} --robust --quiet
  '';
}
