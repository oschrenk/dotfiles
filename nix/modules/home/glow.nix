# glow — render markdown in the terminal. Used by the `woman` fish function.
# Migrated from chezmoi (home/private_dot_config/private_glow/).
{ pkgs, ... }:
{
  home.packages = [ pkgs.glow ];

  # No upstream HM module, and the comments document what each value means, so
  # the file is deployed verbatim.
  xdg.configFile."glow/glow.yml".source = ./glow/glow.yml;
}
