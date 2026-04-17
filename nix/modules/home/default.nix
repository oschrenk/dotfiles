{ username, ... }:

{
  imports = [
    ./git.nix
    ./starship.nix
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";

  # Set once to the HM version used when first applying.
  # Never change this — it tells HM which backwards-incompatible state migrations to skip.
  home.stateVersion = "25.11";
}
