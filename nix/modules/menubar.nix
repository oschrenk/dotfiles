{ ... }:

# https://github.com/nix-darwin/nix-darwin/blob/master/modules/system/defaults/controlcenter.nix
{
  system.defaults.controlcenter = {
    # Always show Sound in menubar
    Sound = true;
    # Always show Focus Modes in menubar
    FocusModes = true;
    # Never show Now Playing in menubar
    NowPlaying = false;
  };

  system.defaults.CustomUserPreferences = {
    # Clock format in menubar: "d. MMM HH:mm" => e.g. "17. Apr 17:58"
    # Not exposed as a native nix-darwin option
    "com.apple.menuextra.clock" = {
      DateFormat = "d. MMM HH:mm";
    };

    # WiFi and Battery visibility have no native nix-darwin options yet
    # Tracking: https://github.com/nix-darwin/nix-darwin/pull/1347
    "com.apple.controlcenter" = {
      # Show WiFi
      "NSStatusItem Visible WiFi" = 1;
      # Show Battery icon — note: BatteryShowPercentage is a different option
      "NSStatusItem Visible Battery" = 1;
    };

    # Always hide menubar in fullscreen — not a native nix-darwin option
    # 0 = always hide, 1 = always show, 2 = auto
    NSGlobalDomain = {
      AppleMenuBarVisibleInFullscreen = 0;
    };

    # Hide input source switcher
    "com.apple.TextInputMenu" = {
      visible = 0;
    };

    # Hide Siri from menubar
    "com.apple.Siri" = {
      StatusMenuVisible = 0;
    };
  };
}
