{ lib, ... }:

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
    persistent-apps = [ ];

    # Group windows by application — helps with aerospace
    # Requires: killall Dock
    expose-group-apps = true;
  };

  # nix-darwin only restarts the Dock when it detects the plist changed during
  # that activation run. When persistent-apps is already empty in the plist but
  # the live Dock still shows stale pins, no restart fires and the change never
  # surfaces. Restart unconditionally so every `task nix:rebuild:darwin` reloads the
  # Dock from the plist. mkAfter runs it after activateSettings -u has applied
  # the defaults; killall is cheap and only a brief flicker.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    killall Dock 2>/dev/null || true
  '';
}
