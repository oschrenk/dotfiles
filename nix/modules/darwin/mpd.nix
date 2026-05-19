# MPD launchd user agent.
#
# We manage the agent ourselves instead of relying on `brew services start mpd`
# because brew's plist runs `mpd --no-daemon` with no config arg, and mpd's
# brew build doesn't auto-discover $XDG_CONFIG_HOME/mpd/mpd.conf — only
# ~/.mpdconf, ~/.mpd/mpd.conf, and /opt/homebrew/etc/mpd.conf are searched.
# Passing the config path explicitly here keeps the config at the XDG-correct
# location chezmoi manages.
#
# The mpd binary itself is still installed via homebrew (apps/brew/base.nix),
# because mpd has a long list of native A/V dependencies that homebrew already
# tracks cleanly.
{ config, lib, ... }:
{
  launchd.user.agents.mpd = {
    serviceConfig = {
      ProgramArguments = [
        "/opt/homebrew/opt/mpd/bin/mpd"
        "--no-daemon"
        "/Users/${config.system.primaryUser}/.config/mpd/mpd.conf"
      ];
      RunAtLoad = true;
      KeepAlive = { SuccessfulExit = false; };
      StandardOutPath = "/Users/${config.system.primaryUser}/.local/state/mpd/launchd.log";
      StandardErrorPath = "/Users/${config.system.primaryUser}/.local/state/mpd/launchd.log";
    };
  };
}
