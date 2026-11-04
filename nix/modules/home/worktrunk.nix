{ config, osConfig, ... }:
{
  home.file.".config/worktrunk/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${osConfig.my.host.dotfiles}/config/worktrunk/config.toml";
}
