{ ... }:

# IINA preferences
#
# Some settings are expressed as an absent key rather than a value — the app
# checks whether the key exists at all, not what it is set to. nix-darwin's
# CustomUserPreferences can only write values, never delete keys, so those
# settings are handled via activationScripts instead.
{
  system.defaults.CustomUserPreferences = {
    "com.colliderli.iina" = {
      # Don't record playback history
      recordPlaybackHistory = 0;

      # Don't show Open Recent menu
      recordRecentFiles = 0;

      # Arrow buttons rewind/forward (0 = seek, 1 = playlist, 2 = rewind/forward)
      arrowBtnAction = 2;

      # Don't keep window open after playback ends
      keepOpenOnFileEnd = 0;

      # Don't open new windows for each file
      alwaysOpenInNewWindow = 0;

      # Quit when last window is closed
      quitWhenNoOpenedWindow = 1;

      # yt-dlp binary path
      ytdlSearchPath = "/opt/homebrew/bin/yt-dlp";

      # Don't autoplay next item in playlist
      playlistAutoPlayNext = 0;

      # Don't seek with horizontal scroll
      horizontalScrollAction = 2;
    };
  };

  system.activationScripts = {
    # Resume last playback position: absent key = resume on, false = resume off
    iina-resume-last-position.text = ''
      defaults delete "com.colliderli.iina" "resumeLastPosition" 2>/dev/null || true
    '';

    # yt-dlp enabled: absent key = enabled (when ytdlSearchPath is set), false = disabled
    iina-ytdl-enabled.text = ''
      defaults delete "com.colliderli.iina" "ytdlEnabled" 2>/dev/null || true
    '';
  };
}
