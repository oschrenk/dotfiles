{ config, lib, pkgs, ... }:

let
  jsonFormat = pkgs.formats.json { };
in

# Keeps Time Machine from backing up anything git already ignores.
#
# Was `brew services start tmignore-rs`, driven by a chezmoi script and a
# `task services` entry. Both are gone, and brew had never actually loaded the
# job: `tmignore-rs stats last-update` reported `never` for as long as the
# formula was installed.
{
  home.packages = [ pkgs.tmignore-rs ];

  # tmignore-rs reads this and never writes it, so a read-only store symlink is
  # fine. It also watches the file and reloads on change, which means a rebuild
  # is enough to apply an edit here.
  #
  # `~` is expanded by tmignore-rs itself, not by the shell, so the tildes below
  # are literal and must stay that way.
  xdg.configFile."tmignore-rs/config.json".source =
    jsonFormat.generate "tmignore-rs-config.json" {
      # Everything under $HOME is a candidate; the exclusions below carve out the
      # directories that hold no git repositories worth scanning.
      search_directories = [ "~" ];
      ignored_directories = [
        "~/.Trash"
        "~/Applications"
        "~/Downloads"
        "~/Library"
        "~/Movies"
        "~/Music"
        "~/Pictures"
      ];
      # Paths matching these are never excluded from Time Machine, even when git
      # ignores them. Empty means the gitignores decide on their own.
      whitelist_patterns = [ ];
      threads = 2;
      # How long to wait after a file change before rescanning.
      debounce_duration = "2s";
    };

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
