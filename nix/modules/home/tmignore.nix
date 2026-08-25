{ config, lib, pkgs, ... }:

let
  jsonFormat = pkgs.formats.json { };

  # `~` is expanded by tmignore-rs itself, not by the shell, so the tildes below
  # are literal and must stay that way.
  configFile = jsonFormat.generate "tmignore-rs-config.json" {
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
in

# Keeps Time Machine from backing up anything git already ignores.
#
# Was `brew services start tmignore-rs`, driven by a chezmoi script and a
# `task services` entry. Both are gone, and brew had never actually loaded the
# job: `tmignore-rs stats last-update` reported `never` for as long as the
# formula was installed.
{
  home.packages = [ pkgs.tmignore-rs ];

  # For the CLI. `tmignore-rs list` and friends read this path by default; the
  # agent is pointed at the store path directly, see below.
  xdg.configFile."tmignore-rs/config.json".source = configFile;

  launchd.agents.tmignore-rs = {
    enable = true;
    config = {
      # `monitor` opens with a full scan before it starts watching, so loading
      # the agent is enough to bring the exclusion list up to date. There is no
      # separate one-shot step to run first.
      # --config names the store path rather than letting the agent find
      # ~/.config/tmignore-rs/config.json on its own. That puts the config's
      # hash in this plist, so editing the config changes the agent and
      # home-manager restarts it.
      #
      # Without it the config change is invisible to the running process. The
      # reload watcher fires while home-manager is mid-swap, reads a file that
      # is not there yet, logs "Due to an error the configuration stay
      # unchanged", and keeps serving what it read at startup.
      ProgramArguments = [
        (lib.getExe pkgs.tmignore-rs)
        "--config"
        "${configFile}"
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
