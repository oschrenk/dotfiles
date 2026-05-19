# MPD (Music Player Daemon) and mpc (the CLI client).
#
# services.mpd takes care of the launchd user agent on darwin and writes
# mpd.conf from typed options + extraConfig. mpc is just a package install.
#
# Pre-rebuild manual steps documented in plans/mpd-mpc-to-hm.md:
#   - launchctl bootout gui/$UID/org.nixos.mpd  (drop the old user agent)
#   - rm ~/.config/mpd/mpd.conf                  (let HM write the symlink)
#
# Caveat: the nixpkgs mpd 0.24.10 darwin build has no inotify. `auto_update yes`
# below is therefore a no-op; manual nudge via `mpc update` happens in
# ~/.config/fish/functions/music.fish.
{ config, pkgs, lib, ... }:
let
  stateDir = "${config.xdg.stateHome}/mpd";
in
{
  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Music";

    # dataDir defaults to $XDG_DATA_HOME/mpd — leave it. Preserve the existing
    # db filename so mpd doesn't rebuild the tag cache on first start
    # (services.mpd's default is "tag_cache").
    dbFile = "${config.xdg.dataHome}/mpd/database";

    network = {
      listenAddress = "127.0.0.1";
      port = 6600;
    };

    extraConfig = ''
      # Override services.mpd's darwin log default (~/Library/Logs/mpd/log.txt)
      # to keep logs under XDG_STATE_HOME, matching the rest of mpd state.
      log_file            "${stateDir}/log"
      pid_file            "${stateDir}/pid"

      # No-op on the nixpkgs darwin build (no inotify, 0.24.10). Kept so it
      # starts working automatically if a future build enables inotify.
      # Workaround until then: music.fish ends with `mpc update`.
      auto_update         "yes"

      audio_output {
          type            "osx"
          name            "CoreAudio"
      }
    '';
  };

  # mpc — the CLI client. Used by music.fish to trigger `mpc update`.
  # nixpkgs renamed `mpc-cli` → `mpc` on 2025-10-27.
  home.packages = [ pkgs.mpc ];

  # services.mpd does not create dataDir / playlistDirectory / our log dir on
  # darwin (only the systemd path has ExecStartPre = mkdir). Without this the
  # daemon fails on first start with
  #   Failed to open "<dataDir>/state": No such file or directory.
  home.activation.mpdStateDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p \
      ${lib.escapeShellArg config.services.mpd.dataDir} \
      ${lib.escapeShellArg config.services.mpd.playlistDirectory} \
      ${lib.escapeShellArg stateDir}
  '';
}
