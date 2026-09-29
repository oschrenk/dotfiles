_:

{
  programs.nix-plist-manager.options.applications.systemSettings.keyboard.keyboardShortcuts = {
    missionControl = {
      moveLeftASpace = false;
      moveRightASpace = false;
      switchToDesktop1 = false;
    };
    inputSources = {
      # keep ^Space free for tmux
      selectThePreviousInputSource = false;
    };
    appShortcuts.menuItems."com.apple.iCal" = {
      "Show Calendar List" = "⌘S";
      "Hide Calendar List" = "⌘S";
    };
  };
}
