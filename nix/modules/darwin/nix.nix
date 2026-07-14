# General Nix daemon settings for darwin hosts.
# Determinate Nix manages its own daemon (nix.enable = false in common.nix), so
# nix-darwin's `nix.settings` are inert. Custom nix.conf settings are written via
# this drop-in, which Determinate includes. Multiple modules may contribute to
# it (the option is a `lines` type and merges); builder-specific settings live
# in linux-builder.nix.
{ ... }:
{
  environment.etc."nix/nix.custom.conf".text = ''
    trusted-users = oliver

    extra-substituters = https://nixos-raspberrypi.cachix.org https://oschrenk.cachix.org
    extra-trusted-public-keys = nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI= oschrenk.cachix.org-1:3JOMfkq2vFiLw4UsCVwzu8kWFBkuS/3DD5AojcO9pks=
  '';
}
