{ ... }:

# Configures PAM for TouchID sudo support, including inside tmux.
# Uses sudo_local which survives macOS upgrades (unlike patching /etc/pam.d/sudo).
# See: https://github.com/nix-darwin/nix-darwin/pull/1344
{
  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;
}
