{ config, pkgs, ... }:

# Setting the default shell in nix-darwin is unreliable without users.knownUsers.
# See:
#   https://github.com/nix-darwin/nix-darwin/issues/1237
#   https://github.com/nix-darwin/nix-darwin/issues/779
#   https://github.com/nix-darwin/nix-darwin/issues/811
#
# If the shell still doesn't change after applying, run manually:
#   chsh -s /run/current-system/sw/bin/fish
{
  # Install fish via nix (not Homebrew) to avoid sequencing issues
  environment.systemPackages = [ pkgs.fish ];

  # Enable fish — adds nix fish path to /etc/shells
  programs.fish.enable = true;

  # Homebrew installs completions to its own vendor dir, which Nix-managed fish
  # doesn't include automatically. Add it so e.g. `task` completions work.
  programs.fish.shellInit = ''
    set -a fish_complete_path /opt/homebrew/share/fish/vendor_completions.d
  '';

  # Register the user so nix-darwin can manage their shell
  users.knownUsers = [ config.my.personal.username ];
  users.users.${config.my.personal.username} = {
    # uid 501 is the first user on macOS — reliable in practice
    uid = 501;
    home = "/Users/${config.my.personal.username}";
    shell = pkgs.fish;
  };
}
