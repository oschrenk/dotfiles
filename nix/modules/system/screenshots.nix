{ config, ... }:

# https://github.com/nix-darwin/nix-darwin/blob/master/modules/system/defaults/screencapture.nix
{
  system.defaults.screencapture = {
    # Save screenshots as PNG
    type = "png";
    # Save screenshots to ~/Downloads — derived from system.primaryUser set in host config
    location = "/Users/${config.system.primaryUser}/Downloads";
  };
}
