{ config, ... }:

# nix/modules/home/rex.nix writes Workspace.customThemes.
{
  system.defaults.CustomUserPreferences = {
    "com.superlogical.rex" = {
      # Bleeding Edge update channel
      "rex.developer-mode-enabled" = true;
      RexAppUpdateChannel = "snapshot";


      "rex.client.remoteControl" = true;
      "rex.agents.names-sessions" = false;

      "Workspace.appIconVisibility" = "dockOnly";
      "Workspace.paneDensity" = "compact";
      "Workspace.tabStyle" = "vertical";
      "Workspace.terminalStartupCommand" = "/Users/${config.my.personal.username}/.config/rex/startup.sh";

      "Workspace.terminalFontName" = "Maple Mono Normal NF";
      "Workspace.terminalFontPointSize" = 28.0;

      # Fixed IDs from config/rex/custom-themes.json
      "Workspace.darkThemeID" = "custom-5618B6EC-9265-4408-942B-CBBAC26BF558";
      "Workspace.lightThemeID" = "custom-4C812174-2DEA-4226-B8C3-3EC827D673E6";
    };
  };
}
