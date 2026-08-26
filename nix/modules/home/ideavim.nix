# IdeaVim — vim emulation inside the JetBrains IDEs. The IDE itself is a brew
# cask, so only the rc file is managed here.
# Migrated from chezmoi (home/private_dot_config/ideavim/).
{ ... }:
{
  # No package: the plugin ships with IntelliJ and is installed from inside it.
  #
  # Deployed verbatim, because the file is vim script. IdeaVim reads it from
  # $XDG_CONFIG_HOME/ideavim/ideavimrc, and only reads it, so a read-only store
  # symlink is fine. `:source ~/.config/ideavim/ideavimrc` reloads it without an
  # IDE restart.
  xdg.configFile."ideavim/ideavimrc".source = ./ideavim/ideavimrc;
}
