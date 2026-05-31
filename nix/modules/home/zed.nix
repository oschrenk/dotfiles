# Zed editor. Package is installed at the system level via nix-darwin
# (see nix/modules/packages.nix) so Zed.app gets linked into
# /Applications/Nix Apps/. This module owns only the settings file.
{ ... }:
{
  xdg.configFile."zed/settings.json".source = ./zed/settings.json;
}
