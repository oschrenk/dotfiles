# General Nix daemon settings for darwin hosts.
# Determinate Nix manages its own daemon (nix.enable = false in common.nix), so
# nix-darwin's `nix.settings` are inert. Custom nix.conf settings are written via
# this drop-in, which Determinate includes. The option is a `lines` type, so
# multiple modules may contribute to it.
{ lib, ... }:
{
  environment.etc."nix/nix.custom.conf".text = ''
    trusted-users = oliver

    extra-substituters = https://oschrenk.cachix.org https://nixos-raspberrypi.cachix.org
    extra-trusted-public-keys = oschrenk.cachix.org-1:3JOMfkq2vFiLw4UsCVwzu8kWFBkuS/3DD5AojcO9pks= nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI=
  '';

  # darwin-rebuild does not restart Determinate's daemon, so a drop-in change
  # sits unread until the next reboot.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    launchctl print system/systems.determinate.nix-daemon >/dev/null 2>&1 && \
      launchctl kickstart -k system/systems.determinate.nix-daemon >/dev/null 2>&1 || true
  '';
}
