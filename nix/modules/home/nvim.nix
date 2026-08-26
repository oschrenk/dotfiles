# neovim config. The editor itself is still the `neovim` brew formula; this
# module only decides who deploys ~/.config/nvim.
# Migrated from chezmoi (home/private_dot_config/nvim/).
{ config, osConfig, ... }:
{
  # Out of the store, into the working copy. Three things in this tree are
  # written by neovim or its plugins rather than by hand, and all three are
  # wanted in git:
  #
  #   lazy-lock.json      lazy.nvim rewrites it on plugin update
  #   spell/*.add         `zg` appends to it
  #   spell/*.spl, *.sug  regenerated from the .add files
  #
  # A store symlink would be read-only, so lazy could not record an update and
  # `zg` could not add a word. It would also mean a rebuild before any lua edit
  # could be tested.
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${osConfig.my.personal.dotfiles}/config/nvim";
}
