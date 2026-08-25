{ config, lib, pkgs, ... }:

# Keeps Time Machine from backing up anything git already ignores.
#
# Was `brew services start tmignore-rs`, driven by a chezmoi script and a
# `task services` entry. Both are gone, and brew had never actually loaded the
# job: `tmignore-rs stats last-update` reported `never` for as long as the
# formula was installed.
{
  home.packages = [ pkgs.tmignore-rs ];

  launchd.agents.tmignore-rs = {
    enable = true;
    config = {
      # `monitor` opens with a full scan before it starts watching, so loading
      # the agent is enough to bring the exclusion list up to date. There is no
      # separate one-shot step to run first.
      ProgramArguments = [
        (lib.getExe pkgs.tmignore-rs)
        "monitor"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      # The brew service sent both streams to /dev/null, which is why nothing
      # showed that it had never started. Keep them readable.
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/tmignore-rs.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/tmignore-rs.log";
    };
  };
}
