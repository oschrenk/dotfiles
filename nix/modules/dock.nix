{ ... }:

# https://github.com/nix-darwin/nix-darwin/blob/master/modules/system/defaults/dock.nix
{
  system.defaults.dock = {
    # Sets "System Preferences > Dock & Menu Bar > Dock > Automatically hide and show the Dock"
    # Requires: killall Dock
    autohide = true;

    # No UI available
    # Requires: killall Dock
    autohide-delay = 0.0;

    # Sets "System Preferences > Dock & Menu Bar > Dock > Position on screen"
    # Requires: killall Dock
    # left | bottom | right
    orientation = "bottom";

    # Sets "System Preferences > Dock & Menu Bar > Dock > Size"
    # Requires: killall Dock
    tilesize = 56;

    # Sets "System Preferences > Dock & Menu Bar > Magnification"
    # Requires: killall Dock
    magnification = false;

    # Clear all pinned apps (replaces dockutil unpinning)
    persistent-apps = [];

    # Group windows by application — helps with aerospace
    # Requires: killall Dock
    expose-group-apps = true;
  };
}
