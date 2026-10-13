# ghostty terminal. The app is a local build of the oschrenk/ghostty fork in
# ~/Applications/Ghostty.app, not a Homebrew cask: the cask shares its bundle
# id, and its uninstall and zap steps would quit and wipe the fork's state.
# nixpkgs ghostty is linux-only, so there is no darwin package to install here.
#
# Deployed verbatim instead of via programs.ghostty.settings: the config is
# ~70% comments, including the splits decision log, and the settings generator
# renders structured data only and drops every comment.
_:
{
  xdg.configFile."ghostty/config".source = ./ghostty/config;
}
