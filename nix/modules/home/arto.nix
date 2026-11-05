{ arto, pkgs, ... }:

# arto — remote approval for Claude Code via ntfy push notifications.
#
# Package only: the upstream flake exposes packages and apps but no
# home-manager module. Fish completions ship inside the package.
{
  home.packages = [ arto.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
