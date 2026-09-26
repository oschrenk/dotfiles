{ config, ... }:

# What nix-plist-manager cannot express; the rest of Finder lives in
# defaults/user/finder.nix.
{
  system.defaults.finder = {
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
    NewWindowTargetPath = "file:///Users/${config.my.personal.username}/Downloads/";

    # Set preferred view style
    # Icon View   : icnv
    # List View   : Nlsv
    # Column View : clmv
    # Cover Flow  : Flwv
    # Requires: deletion of ~/.DS_Store
    FXPreferredViewStyle = "clmv";
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
