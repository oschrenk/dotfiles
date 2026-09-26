{ ... }:

# The software update domains are root-owned, so the setting only exists in
# the darwin module, not in home-manager.
{
  programs.nix-plist-manager.options.applications.systemSettings.general.softwareUpdate = {
    automaticallyDownloadNewUpdatesWhenAvailable = true;
    automaticallyInstallApplicationUpdatesFromTheAppStore = true;
    automaticallyInstallMacOSUpdates = true;
    automaticallyInstallSystemDataFilesAndSecurityUpdates = true;
  };
}
