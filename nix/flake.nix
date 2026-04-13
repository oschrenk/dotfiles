{
  description = "Oliver's nix-darwin configuration";

  inputs = {
    # unstable ensures nix-darwin modules and packages don't break on missing
    # nixpkgs features; switch to nixpkgs-stable if you prefer slower updates
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    # pin nix-darwin to the same nixpkgs to avoid a second copy on disk
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nix-darwin, nixpkgs, ... }:
    {
      # Official Nix formatter: https://github.com/NixOS/nixfmt
      # nixfmt-rfc-style in nixpkgs is the same tool, just a confusing alias
      # Run with: nix fmt
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;

      darwinConfigurations = {
        "Olivers-MaxBook" = nix-darwin.lib.darwinSystem {
          modules = [
            ./modules/common.nix
            ./modules/pam.nix
            ./modules/system/accessibility.nix
            ./modules/system/desktop.nix
            ./modules/system/dock.nix
            ./modules/system/finder.nix
            ./modules/system/hotkeys.nix
            ./modules/system/keyboard.nix
            ./modules/system/menubar.nix
            ./modules/system/screenshots.nix
            ./modules/system/siri.nix
            ./modules/system/spotlight.nix
            ./modules/system/timemachine.nix
            ./hosts/maxbook.nix
          ];
        };
      };
    };
}
