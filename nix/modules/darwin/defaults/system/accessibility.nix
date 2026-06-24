{ config, lib, ... }:

# https://github.com/nix-darwin/nix-darwin/blob/master/modules/system/defaults/universalaccess.nix
{
  system.defaults.universalaccess = {
    # Use ⌘+scroll gesture to zoom.
    #
    # com.apple.universalaccess is a TCC-protected domain: nix-darwin can only
    # write it when the terminal running the switch has Full Disk Access. On a
    # fresh machine the first switch runs in Terminal.app (Ghostty is not
    # installed yet), so this silently no-ops and prints:
    #   defaults[...]: Could not write domain com.apple.universalaccess; exiting
    # Fix: grant Full Disk Access to that terminal, then re-run `task nix-max`.
    # The preActivation probe below warns up front when this write would fail
    # (it runs before the write, which aborts activation, so a post-check would
    # never execute).
    closeViewScrollWheelToggle = true;
  };

  system.defaults.CustomUserPreferences = {
    # HIDScrollZoomModifierMask: modifier key for scroll-to-zoom gesture
    # 1048576 = Command (⌘)
    # Not exposed as a native nix-darwin option
    "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
      HIDScrollZoomModifierMask = 1048576;
    };
  };

  # Warn (on stderr) before nix-darwin writes system.defaults when the terminal
  # lacks Full Disk Access. The universalaccess write is TCC-gated and its
  # failure aborts activation, so a postActivation check would never run. Probe
  # with a throwaway write as the primary user: if it fails, FDA is missing.
  system.activationScripts.preActivation.text = lib.mkAfter ''
    if ! sudo -u ${config.my.personal.username} defaults write com.apple.universalaccess __fdaProbe -bool true 2>/dev/null; then
      echo "" >&2
      echo "WARNING: no Full Disk Access for this terminal. The com.apple.universalaccess" >&2
      echo "  write below will fail and abort activation. Grant Full Disk Access (Terminal.app" >&2
      echo "  on a fresh machine, Ghostty afterwards), quit and reopen it, then re-run." >&2
    else
      sudo -u ${config.my.personal.username} defaults delete com.apple.universalaccess __fdaProbe 2>/dev/null || true
    fi
  '';
}
