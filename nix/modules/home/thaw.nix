{ thaw, pkgs, ... }:

# thaw — previews what a flake input bump changes: per-subject package diffs
# and the home-manager news entries an update brings.
#
# Package only: the upstream flake exposes packages and apps but no
# home-manager module, and thaw reads flake.lock rather than a config file.
# Fish completions ship inside the package. `task nix:update:preview` is the
# consumer; the options half of that preview stays a script, because
# `thaw options` reads NixOS options alone.
{
  home.packages = [ thaw.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
