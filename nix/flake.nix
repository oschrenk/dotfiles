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
            ./modules/packages.nix
            ./modules/brew/settings.nix
            ./modules/pam.nix
            ./modules/shell.nix
            ./modules/system/defaults/accessibility.nix
            ./modules/system/defaults/desktop.nix
            ./modules/system/defaults/dock.nix
            ./modules/system/defaults/finder.nix
            ./modules/system/defaults/hotkeys.nix
            ./modules/system/defaults/keyboard.nix
            ./modules/system/defaults/menubar.nix
            ./modules/system/defaults/screenshots.nix
            ./modules/system/defaults/siri.nix
            ./modules/system/defaults/spotlight.nix
            ./modules/system/defaults/timemachine.nix
            ./hosts/maxbook.nix
          ];
        };
      };
    };
}
