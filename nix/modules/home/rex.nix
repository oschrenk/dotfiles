{ config, osConfig, ... }:
{
  home.file.".config/rex".source =
    config.lib.file.mkOutOfStoreSymlink "${osConfig.my.host.dotfiles}/config/rex";
}
