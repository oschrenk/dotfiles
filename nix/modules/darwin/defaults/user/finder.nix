{ ... }:

{
  programs.nix-plist-manager.options.applications = {
    finder = {
      menuBar.view = {
        showPathBar = true;
        showStatusBar = false;
      };
      settings = {
        general.openFoldersInTabsInsteadOfNewWindows = false;
        advanced = {
          showAllFilenameExtensions = true;
          showWarningBeforeChangingAnExtension = false;
          whenPerformingASearch = "Search the Current Folder";
          keepFoldersOnTop.inWindowsWhenSortingByName = true;
        };
      };
    };
    # spring loading for directories (drag over folder to open it)
    systemSettings.accessibility.pointerControl = {
      springLoading = true;
      springLoadingSpeed = 0.2;
    };
  };
}
