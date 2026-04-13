{ config, ... }:

# nix-darwin has no native Time Machine options.
# tmutil addexclusion is idempotent so safe to run on every activation.
{
  system.activationScripts.timemachine.text = ''
    echo "Time Machine: Excluding directories from backups"
    tmutil addexclusion /Users/${config.system.primaryUser}/Downloads
    tmutil addexclusion /Users/${config.system.primaryUser}/Movies
  '';
}
