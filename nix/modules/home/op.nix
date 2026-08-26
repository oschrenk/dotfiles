# 1Password CLI. The binary is a brew cask; only these two files are managed.
# Migrated from chezmoi (home/private_dot_config/private_op/).
{ lib, ... }:
{
  # Declared file by file, never as a directory source. ~/.config/op also holds
  # op's own config, its daemon socket and plugins/used_items state, and a
  # directory symlink would take all of that with it.
  #
  # plugins.sh has a second writer: `op plugin init` appends to it. As a store
  # symlink it is read-only, so a new plugin means adding its alias here rather
  # than letting op do it. fish sources the file behind an `if test -f` guard.
  xdg.configFile."op/plugins.sh".source = ./op/plugins.sh;

  # chezmoi's private_ prefix kept this directory at 0700 and home-manager
  # creates parent directories at 0755, so restore the mode explicitly.
  home.activation.opConfigMode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    [ -d "$HOME/.config/op" ] && chmod 700 "$HOME/.config/op"
  '';
}
