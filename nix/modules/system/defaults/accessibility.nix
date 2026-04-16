{ ... }:

# https://github.com/nix-darwin/nix-darwin/blob/master/modules/system/defaults/universalaccess.nix
{
  system.defaults.universalaccess = {
    # Use ⌘+scroll gesture to zoom
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
}
