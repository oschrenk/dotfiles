# ghostty terminal. The app itself is the Homebrew cask in
# nix/modules/darwin/brew/gui.nix — nixpkgs ghostty is linux-only, so there is
# no darwin package to install here.
#
# Deployed verbatim instead of via programs.ghostty.settings: the config is
# ~70% comments, including the splits decision log, and the settings generator
# renders structured data only and drops every comment.
{ ... }:
{
  xdg.configFile."ghostty/config".source = ./ghostty/config;
}
