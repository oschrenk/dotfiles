{ config, osConfig, ... }:
{
  home.file.".config/rex".source =
    config.lib.file.mkOutOfStoreSymlink "${osConfig.my.host.dotfiles}/config/rex";

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
