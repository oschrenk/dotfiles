_:

# sketchybar draws the visible bar; the macOS menu bar stays hidden and only
# appears on hover, so these settings shape that hover state.
{
  programs.nix-plist-manager.options.applications.systemSettings.menuBar = {
    autoHideAndShowTheMenuBar = "Always";
    sound = "Always Show";
    focusModes = "Always Show";
    nowPlaying = "Don't Show";
    wifi = true;
    battery = true;
    textInput = false;
    siri = false;
    clock = {
      showDate = true;
      showTheDayOfTheWeek = false;
    };
  };
}
