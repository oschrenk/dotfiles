{ username, ... }:

{
  imports = [
    ./aerospace.nix
    ./atuin.nix
    ./cottage.nix
    ./direnv.nix
    ./fish.nix
    ./fzf.nix
    ./git.nix
    ./gitwatch.nix
    ./identity.nix
    ./infat.nix
    ./kanata.nix
    ./lsd.nix
    ./mpd.nix
    ./ripgrep.nix
    ./rmpc.nix
    ./sketchybar.nix
    ./starship.nix
    ./tlink.nix
    ./tmux.nix
    ./zed.nix
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

  # We run 
  # nixpkgs-unstable with home-manager master
  #
  # Right after a NixOS release their version strings disagree. (unstable bumps to the next cycle while HM master lags).
  # Silence the warning
  home.enableNixpkgsReleaseCheck = false;
}
