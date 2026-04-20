{
  description = "Oliver's nix-darwin configuration";

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  inputs = {
    # unstable ensures nix-darwin modules and packages don't break on missing
    # nixpkgs features; switch to nixpkgs-stable if you prefer slower updates
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    # pin nix-darwin to the same nixpkgs to avoid a second copy on disk
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    # pin home-manager to the same nixpkgs to avoid a second copy on disk
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      nixos-raspberrypi,
      ...
    }@inputs:
    {
      # Official Nix formatter: https://github.com/NixOS/nixfmt
      # nixfmt-rfc-style in nixpkgs is the same tool, just a confusing alias
      # Run with: nix fmt
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;

      # Bootstrap image — SSH key baked in, flash to USB, deploy pi-1 on first boot
      # Build: nix build .#packages.aarch64-linux.pi-image
      packages.aarch64-linux.pi-image =
        self.nixosConfigurations.pi.config.system.build.sdImage;

      nixosConfigurations = {
        # Bootstrap image config — uses nvmd sd-image module for proper RPi4 firmware
        "pi" = nixos-raspberrypi.lib.nixosSystem {
          specialArgs = inputs;
          modules = [
            nixos-raspberrypi.nixosModules.raspberry-pi-4.base
            nixos-raspberrypi.nixosModules.sd-image
            ./modules/nixos/base.nix
          ];
        };

        "pi-1" = nixos-raspberrypi.lib.nixosSystem {
          specialArgs = inputs;
          modules = [
            nixos-raspberrypi.nixosModules.raspberry-pi-4.base
            ./modules/nixos/base.nix
            ./modules/nixos/pi4-hardware.nix
            ./hosts/pi-1.nix
          ];
        };

        "pi-2" = nixos-raspberrypi.lib.nixosSystem {
          specialArgs = inputs;
          modules = [
            nixos-raspberrypi.nixosModules.raspberry-pi-4.base
            ./modules/nixos/base.nix
            ./modules/nixos/pi4-hardware.nix
            ./hosts/pi-2.nix
          ];
        };
      };

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
            home-manager.darwinModules.home-manager
            ./modules/home-manager.nix
          ];
        };
      };
    };
}
