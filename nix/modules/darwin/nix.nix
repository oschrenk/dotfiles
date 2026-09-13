# General Nix daemon settings for darwin hosts.
# Determinate Nix manages its own daemon (nix.enable = false in common.nix), so
# nix-darwin's `nix.settings` are inert. Custom nix.conf settings are written via
# this drop-in, which Determinate includes. The option is a `lines` type, so
# multiple modules may contribute to it.
{ ... }:
{
  environment.etc."nix/nix.custom.conf".text = ''
    trusted-users = oliver

    extra-substituters = https://oschrenk.cachix.org
    extra-trusted-public-keys = oschrenk.cachix.org-1:3JOMfkq2vFiLw4UsCVwzu8kWFBkuS/3DD5AojcO9pks=
  '';
}
