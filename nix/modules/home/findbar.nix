{ lib, pkgs, ... }:

let
  jsonFormat = pkgs.formats.json { };

  # `~` is expanded by findbar itself, not by the shell, so the tildes below
  # are literal and must stay that way.
  #
  # Omitting `name` would let macOS resolve the localized system-folder name
  # (Downloads/Téléchargements/...). The names below are kept because they are
  # what the sidebar already holds, so the first sync is a no-op.
  configFile = jsonFormat.generate "findbar-config.json" {
    items = [
      { name = "Desktop"; path = "~/Desktop"; }
      { name = "Downloads"; path = "~/Downloads"; }
      { name = "Documents"; path = "~/Documents"; }
      { name = "Watch"; path = "~/Library/Mobile Documents/com~apple~CloudDocs/Watch"; }
      { name = "Miniatures"; path = "~/Library/Mobile Documents/com~apple~CloudDocs/Resources/Miniatures"; }
      { name = "Instagram"; path = "~/Library/Mobile Documents/com~apple~CloudDocs/Resources/Instagram"; }
      { name = "DIY"; path = "~/Library/Mobile Documents/com~apple~CloudDocs/Resources/Images/Raster/DIY"; }
      { name = "Interior"; path = "~/Library/Mobile Documents/com~apple~CloudDocs/Resources/Images/Raster/Interior"; }
    ];
    # false means the list above is the whole sidebar: anything added by hand
    # in Finder is removed on the next rebuild. Set true to keep manual items.
    keep_unmanaged = false;
  };
in

# Declarative Finder sidebar favorites.
#
# Upstream ships its own nix-darwin and home-manager modules, but their
# `package` option defaults to `self.packages.*`, so consuming either one
# requires taking upstream's flake as an input — and with it crane, fenix and
# flake-utils. The module is fifteen lines, so it lives here instead, and
# pkgs.findbar comes from nix/pkgs/findbar.nix.
#
# The home-manager shape is used rather than the darwin one. The darwin module
# runs in postActivation as root and needs `launchctl asuser` plus `sudo -u` to
# get back into the login session; running as the user from the start needs
# none of that.
{
  home.packages = [ pkgs.findbar ];

  # For the CLI, so that `findbar sync ~/.config/findbar/config.json --dry-run`
  # is easy to run by hand.
  xdg.configFile."findbar/config.json".source = configFile;

  # The store path is named directly rather than the ~/.config copy, so the
  # config's hash is part of the activation script and an edit actually
  # re-runs the sync.
  home.activation.findbar = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${lib.getExe pkgs.findbar} sync "${configFile}"
  '';
}
