{ config, lib, ... }:

# nix-darwin has no native Time Machine options.
# tmutil addexclusion is idempotent so safe to run on every activation.
#
# Must hook into postActivation (a hardcoded nix-darwin activation script):
# nix-darwin only runs a fixed set of named activation scripts, so a custom
# name like `timemachine` is silently defined but never executed. mkAfter
# keeps it composable with other modules that also set postActivation.
{
  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo "Time Machine: Excluding directories from backups"
    tmutil addexclusion /Users/${config.system.primaryUser}/Downloads
    tmutil addexclusion /Users/${config.system.primaryUser}/Movies
  '';
}
