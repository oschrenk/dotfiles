{ ... }:

{
  programs.nix-plist-manager.options.applications.systemSettings.appearance = {
    allowWallpaperTintingInWindows = false;
    # how tinted Liquid Glass is, from 0 (clear) to 1 (tinted)
    liquidGlass = 0.4;
    sidebarIconSize = "Large";
  };
}
