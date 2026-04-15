{ ... }:

{
  imports = [
    ../modules/brew/fonts.nix
    ../modules/brew/gui.nix
  ];

  # MaxBook-specific configuration

  # Apple Silicon — use x86_64-darwin for Intel Macs
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Primary user for user-scoped defaults (e.g. Finder, NSGlobalDomain)
  system.primaryUser = "oliver";

  # Set once to the nix-darwin version used when first applying.
  # Never change this — it tells nix-darwin how to handle state migrations.
  # Check current version with: nix run nix-darwin -- --version
  # Or see: https://github.com/nix-darwin/nix-darwin/blob/master/CHANGELOG.md
  system.stateVersion = 6;

  # MaxBook-specific apps (MacBook Pro with extra peripherals)
  homebrew.casks = [
    "8bitdo-ultimate-software" # controller
    "elgato-control-center" # elgato software to control lights
    "live-home-3d" # home designer
    "rode-central" # rode companion app (for AI-1)
    "steam" # games
  ];

  homebrew.masApps = {
    "Affinity Designer 2" = 1616831348; # vector editing
    "Affinity Photo 2" = 1616822987; # raster editing
    "Affinity Publisher 2" = 1606941598; # book publishing
  };
}
