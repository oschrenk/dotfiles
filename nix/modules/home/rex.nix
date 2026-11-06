{
  config,
  lib,
  osConfig,
  ...
}:
{
  home.file.".config/rex".source =
    config.lib.file.mkOutOfStoreSymlink "${osConfig.my.host.dotfiles}/config/rex";

  # CustomUserPreferences cannot write data values.
  home.activation.rexCustomThemes = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run /usr/bin/defaults write com.superlogical.rex Workspace.customThemes \
      -data "$(/usr/bin/xxd -p ${../../../config/rex/custom-themes.json} | tr -d '\n')"
  '';

  launchd.agents.rex-bridge = {
    enable = true;
    config = {
      ProgramArguments = [
        "${config.home.homeDirectory}/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"
        "--autostart=false"
        "do"
        "${config.home.homeDirectory}/.config/rex/bridge.lua"
        "--all"
      ];
      EnvironmentVariables.PATH = "/etc/profiles/per-user/${config.home.username}/bin:/usr/bin:/bin";
      RunAtLoad = true;
      KeepAlive = true;
    };
  };
}
