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

  outputs = { nix-darwin, ... }: {
    darwinConfigurations = {
      "Olivers-MaxBook" = nix-darwin.lib.darwinSystem {
        modules = [
          ./modules/common.nix
          ./modules/dock.nix
          ./modules/finder.nix
          ./modules/hotkeys.nix
          ./modules/keyboard.nix
          ./modules/pam.nix
          ./hosts/maxbook.nix
        ];
      };
    };
  };
}
