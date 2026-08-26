# yt-dlp — download video/audio. The package moved to nixpkgs with gallery-dl;
# this brings its config along so one system owns both.
# Migrated from chezmoi (home/private_dot_config/yt-dlp/).
{ ... }:
{
  # The package is in environment.systemPackages, not here, because IINA
  # interpolates its store path and needs the system-wide one.
  #
  # Deployed verbatim: the file is yt-dlp's own argument syntax, not something
  # a nix attrset would express more clearly.
  xdg.configFile."yt-dlp/config".source = ./yt-dlp/config;
}
