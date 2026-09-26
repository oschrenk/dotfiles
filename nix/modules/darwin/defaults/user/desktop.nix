{ ... }:

{
  programs.nix-plist-manager.options.applications.systemSettings = {
    appearance.allowWallpaperTintingInWindows = false;
    desktopAndDock = {
      dock = {
        automaticallyHideAndShowTheDock = {
          enabled = true;
          delay = 0.0;
        };
        dockPositionOnScreen = "Bottom";
        size = 56;
        magnification.enabled = false;
      };
      hotCorners = {
        topLeft.action = "Mission Control";
        topRight.action = "Mission Control";
        bottomLeft.action = "Desktop";
        bottomRight.action = "Start Screen Saver";
      };
      # helps with aerospace
      missionControl.groupWindowsByApplication = true;
    };
  };
}
