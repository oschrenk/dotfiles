{ ... }:

# https://github.com/nix-darwin/nix-darwin/blob/master/modules/system/defaults/loginwindow.nix
{
  system.defaults.loginwindow = {
    # System Settings > Lock Screen — show only a password prompt, no username
    # or photo.
    HideUserAvatarAndName = true;
  };
}
