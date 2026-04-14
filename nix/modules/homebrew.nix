{ ... }:

# Homebrew package management via nix-darwin.
# Homebrew itself must be installed first (bootstrap.sh handles this).
# darwin-rebuild switch then manages packages declaratively.
let
  # Required before chezmoi can run — installed first on a new machine
  bootstrap = [
    "age" # cryptography, encryption tool
    "chezmoi" # dotfiles manager
    "fish" # shell
    "git" # git, dvcs
    "git-lfs" # git, large file storage
  ];

  # Essential tools installed early so the machine is usable while
  # the rest of the Brewfile keeps installing in the background
  core = [
    "atuin" # cli, improved shell history
    "fd" # system, fast find alternative
    "findutils" # system, GNU g-prefixed find, xargs
    "fzf" # cli, fuzzy finder
    "mas" # cli, Mac App Store interface
    "neovim" # editor
    "oschrenk/made/sessionizer" # tmux, manage sessions
    "ripgrep" # system, recursive search
    "starship" # shell, prompt
    "tmux" # cli, terminal multiplexer
  ];
in
{
  homebrew = {
    enable = true;

    onActivation = {
      # Cleanup strategy for packages no longer declared here:
      #   none      — don't remove anything (safe during migration)
      #   uninstall — remove unlisted packages
      #   zap       — remove unlisted packages + associated data
      # TODO: switch to "zap" once Brewfile is fully migrated from chezmoi
      cleanup = "none";
      # Update Homebrew on each activation
      autoUpdate = true;
    };

    taps = [
      "oschrenk/made" # tools created by oschrenk
    ];

    brews = bootstrap ++ core;

    casks = [
      "1password-cli"
    ];
  };
}
