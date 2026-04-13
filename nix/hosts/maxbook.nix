{ ... }:

{
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
}
