# Neovide — the neovim GUI. The app itself is the neovide-app cask.
# Migrated from chezmoi (home/private_dot_config/neovide/).
{ ... }:
{
  # Deployed verbatim. The comments in the file are neovide's own documentation
  # of what each frame and decoration value does, and an attrset would drop them.
  xdg.configFile."neovide/config.toml".source = ./neovide/config.toml;
}
