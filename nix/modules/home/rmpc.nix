# rmpc (Rust Music Player Client — TUI for MPD).
#
# programs.rmpc.config is types.lines, so we pass config.ron through verbatim
# via builtins.readFile. Comments preserved without round-tripping through any
# attr-to-text serializer.
#
# The HM module doesn't have a `themes` option, so the theme file is deployed
# alongside via xdg.configFile.
{ ... }:
{
  programs.rmpc = {
    enable = true;
    config = builtins.readFile ./rmpc/config.ron;
  };

  xdg.configFile."rmpc/themes/gruvbox.ron".source = ./rmpc/themes/gruvbox.ron;
}
