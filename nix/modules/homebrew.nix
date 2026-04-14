{ ... }:

# Homebrew package management via nix-darwin.
# Homebrew itself must be installed first (bootstrap.sh handles this).
# darwin-rebuild switch then manages packages declaratively.
{
  homebrew = {
    enable = true;

    onActivation = {
      # Cleanup strategy for packages no longer declared here:
      #   none    — don't remove anything (safe during migration)
      #   uninstall — remove unlisted packages
      #   zap     — remove unlisted packages + associated data
      # TODO: switch to "zap" once Brewfile is fully migrated from chezmoi
      cleanup = "none";
      # Update Homebrew on each activation
      autoUpdate = true;
    };

    brews = [
      "age"
      "chezmoi"
      "fish"
      "git"
      "git-lfs"
    ];

    casks = [
      "1password-cli"
    ];
  };
}
