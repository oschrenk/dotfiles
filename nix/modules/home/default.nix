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
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";

  # Set once to the HM version used when first applying.
  # Never change this — it tells HM which backwards-incompatible state migrations to skip.
  home.stateVersion = "25.11";
}
