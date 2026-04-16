{ ... }:

# Note: most options accept raw abbreviation strings (types.str), except
# NewWindowTarget which requires human-readable values. See:
# https://github.com/nix-darwin/nix-darwin/blob/master/modules/system/defaults/finder.nix
{
  system.defaults.finder = {
    # Disable the warning when changing a file extension
    FXEnableExtensionChangeWarning = false;

    # New window location set to ~/Downloads
    # nix-darwin uses human-readable values (not the internal Pf* codes):
    #   Computer
    #   OS volume
    #   Home
    #   Desktop
    #   Documents
    #   Recents
    #   iCloud Drive
    #   Other
    NewWindowTarget = "Other";
    NewWindowTargetPath = "file://$HOME/Downloads/";

    # Toggles View > "Show/Hide Path Bar" — requires closing Finder windows
    ShowPathbar = true;

    # Toggles View > "Show/Hide Status Bar" — requires closing Finder windows
    ShowStatusBar = false;

    # Toggles Finder > Preferences > Advanced > "Show all filename extensions"
    # Requires: killall Finder
    AppleShowAllExtensions = true;

    # Set search scope
    # This Mac       : SCev
    # Current Folder : SCcf
    # Previous Scope : SCsp
    # Requires: killall Finder
    FXDefaultSearchScope = "SCcf";

    # Set preferred view style
    # Icon View   : icnv
    # List View   : Nlsv
    # Column View : clmv
    # Cover Flow  : Flwv
    # Requires: deletion of ~/.DS_Store
    FXPreferredViewStyle = "clmv";
  };

  system.defaults.NSGlobalDomain = {
    # Enable spring loading for directories (drag over folder to open it)
    "com.apple.springing.enabled" = true;
    # Shorten the spring loading delay
    "com.apple.springing.delay" = 0.2;
  };

  system.defaults.CustomUserPreferences = {
    "com.apple.finder" = {
      # Set width of sidebar — requires killall Finder
      SidebarWidth = 150;
      # Group by Kind (not a native nix-darwin option)
      FXPreferredGroupBy = "Kind";
    };
  };
}
