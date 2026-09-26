{ lib, ... }:

# Dock pins are an arrangement, not a System Settings pane, so they stay in
# nix-darwin while the rest of the Dock lives in nix-plist-manager.
{
  # Clear all pinned apps (replaces dockutil unpinning)
  system.defaults.dock.persistent-apps = [ ];

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
