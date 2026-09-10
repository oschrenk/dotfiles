{ cutter, pkgs, ... }:

# cutter — extracts cookies from Safari, Arc and Chrome and prints them as JSON.
#
# Package only: the upstream flake exposes packages and apps but no
# home-manager module, and cutter reads no config file.
#
# Arc and Chrome hold their cookie keys in the login keychain, so the first read
# per browser raises a macOS prompt. "Always Allow" is bound to that one binary
# and that one keychain entry, so an upgrade asks once more.
{
  home.packages = [ cutter.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
