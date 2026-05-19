{ username, ... }:

{
  imports = [
    ./git.nix
    ./starship.nix
    ./atuin.nix
    ./identity.nix
    ./direnv.nix
    ./fish.nix
    ./fzf.nix
    ./lsd.nix
    ./tmux.nix
    ./ripgrep.nix
    ./sketchybar.nix
    ./gitwatch.nix
    ./aerospace.nix
    ./mpd.nix
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";

  # XDG paths. programs.aerospace needs xdg.enable = true to write its config
  # to $XDG_CONFIG_HOME/aerospace/aerospace.toml instead of the legacy
  # ~/.aerospace.toml. Other HM modules use xdg.configFile directly and are
  # unaffected by this flag.
  xdg.enable = true;

  # Set once to the HM version used when first applying.
  # Never change this — it tells HM which backwards-incompatible state migrations to skip.
  home.stateVersion = "25.11";
}
