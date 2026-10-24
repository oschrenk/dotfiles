{ config, ... }:
{
  launchd.agents.despacer = {
    enable = true;
    config = {
      ProgramArguments = [ "/Applications/Nix Apps/Despacer.app/Contents/MacOS/Despacer" ];
      RunAtLoad = true;
      ProcessType = "Interactive";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/despacer.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/despacer.log";
    };
  };
}
