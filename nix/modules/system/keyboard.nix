{ lib, ... }:

# https://github.com/nix-darwin/nix-darwin/blob/master/modules/system/defaults/NSGlobalDomain.nix
{
  warnings = [
    "Keyboard: KeyRepeat and InitialKeyRepeat require logout to take effect"
  ];

  system.defaults.NSGlobalDomain = {
    # Key repeat rate — default: 2 (30ms), normal minimum: 2
    # Experiment with speeds: https://mac-os-key-repeat.vercel.app/
    KeyRepeat = 5;

    # Initial key repeat delay — default: 68 (1020ms), normal minimum: 15 (225ms)
    # Experiment with speeds: https://mac-os-key-repeat.vercel.app/
    InitialKeyRepeat = 10;

    # Disable auto capitalization
    NSAutomaticCapitalizationEnabled = false;

    # Disable "smart" dashes
    NSAutomaticDashSubstitutionEnabled = false;

    # Disable automatic period substitution
    NSAutomaticPeriodSubstitutionEnabled = false;

    # Disable smart quotes
    NSAutomaticQuoteSubstitutionEnabled = false;

    # Keyboard navigation mode — controls tab focus behavior
    # 0 = text fields and lists only (macOS default)
    # 2 = all controls (buttons, checkboxes, etc.)
    # Maps to System Settings > Keyboard > "Keyboard navigation"
    AppleKeyboardUIMode = 2;
  };

  system.defaults.CustomUserPreferences = {
    # HIToolbox is the macOS framework handling keyboard input and function keys.
    # Not exposed as a native nix-darwin option, so set via CustomUserPreferences.
    "com.apple.HIToolbox" = {
      # Controls what the Fn key does when pressed alone
      # 0 = do nothing
      # 1 = change input source
      # 2 = show emoji & symbols picker
      # 3 = start dictation
      AppleFnUsageType = 0;
    };
  };
}
