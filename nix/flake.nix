{
  description = "Oliver's nix-darwin configuration";

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
    opnix.url = "github:brizzbuzz/opnix";
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      nixos-raspberrypi,
      opnix,
      ...
    }@inputs:
    {
      # Official Nix formatter: https://github.com/NixOS/nixfmt
      # nixfmt-rfc-style in nixpkgs is the same tool, just a confusing alias
      # Run with: nix fmt
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;

      # Bootstrap image — SSH key baked in, flash to USB, deploy pi-1 on first boot
      # Build: nix build .#packages.aarch64-linux.pi-image
      packages.aarch64-linux.pi-image = self.nixosConfigurations.pi.config.system.build.sdImage;

      nixosConfigurations = {
        # Bootstrap image config — uses nvmd sd-image module for proper RPi4 firmware
        "pi" = nixos-raspberrypi.lib.nixosSystem {
          specialArgs = inputs;
          modules = [
            ./local.nix
            ./options.nix
            nixos-raspberrypi.nixosModules.raspberry-pi-4.base
            nixos-raspberrypi.nixosModules.sd-image
            ./modules/nixos/base.nix
          ];
        };

        "pi-1" = nixos-raspberrypi.lib.nixosSystem {
          specialArgs = inputs;
          modules = [
            ./local.nix
            ./options.nix
            nixos-raspberrypi.nixosModules.raspberry-pi-4.base
            opnix.nixosModules.default
            ./modules/nixos/base.nix
            ./modules/nixos/pi4-hardware.nix
            ./modules/nixos/secrets.nix
            ./modules/nixos/step-ca.nix
            ./modules/nixos/homelab.nix
            ./modules/nixos/homepage.nix
            ./modules/nixos/beszel/hub.nix
            ./modules/nixos/beszel/agent.nix
            ./modules/nixos/restic/healthcheck.nix
            ./modules/nixos/restic/beszel.nix
            ./modules/nixos/gatus.nix
            ./modules/nixos/adguard.nix
            ./modules/nixos/restic/adguard.nix
            ./modules/nixos/restic/step-ca.nix
            ./sites/home.lan.nix
            ./hosts/pi-1.nix
          ];
        };

        "pi-2" = nixos-raspberrypi.lib.nixosSystem {
          specialArgs = inputs;
          modules = [
            ./local.nix
            ./options.nix
            nixos-raspberrypi.nixosModules.raspberry-pi-4.base
            opnix.nixosModules.default
            ./modules/nixos/base.nix
            ./modules/nixos/pi4-hardware.nix
            ./modules/nixos/secrets.nix
            ./modules/nixos/beszel/agent.nix
            ./hosts/pi-2.nix
          ];
        };

        "pi-3" = nixos-raspberrypi.lib.nixosSystem {
          specialArgs = inputs;
          modules = [
            ./local.nix
            ./options.nix
            nixos-raspberrypi.nixosModules.raspberry-pi-4.base
            opnix.nixosModules.default
            ./modules/nixos/base.nix
            ./modules/nixos/pi4-hardware.nix
            ./modules/nixos/secrets.nix
            ./modules/nixos/beszel/agent.nix
            ./modules/nixos/unifi-network-controller.nix
            ./hosts/pi-3.nix
          ];
        };
      };

      darwinConfigurations = {
        "Olivers-MaxBook" = nix-darwin.lib.darwinSystem {
          modules = [
            ./local.nix
            ./options.nix
            ./modules/common.nix
            ./modules/packages.nix
            ./modules/darwin/brew/settings.nix
            ./modules/shell.nix
            ./modules/darwin/defaults/system/accessibility.nix
            ./modules/darwin/defaults/system/desktop.nix
            ./modules/darwin/defaults/system/dock.nix
            ./modules/darwin/defaults/system/finder.nix
            ./modules/darwin/defaults/system/hotkeys.nix
            ./modules/darwin/defaults/system/keyboard.nix
            ./modules/darwin/defaults/system/menubar.nix
            ./modules/darwin/defaults/system/screenshots.nix
            ./modules/darwin/defaults/system/siri.nix
            ./modules/darwin/defaults/system/spotlight.nix
            ./modules/darwin/defaults/system/timemachine.nix
            ./modules/darwin/defaults/apps/com.apple.ical.nix
            ./modules/darwin/defaults/apps/com.apple.maps.nix
            ./modules/darwin/defaults/apps/com.google.chrome.nix
            ./modules/darwin/defaults/apps/com.reederapp.5.macos.nix
            ./modules/darwin/defaults/apps/com.jetbrains.intellij.nix
            ./modules/darwin/defaults/apps/com.nordvpn.nordvpn.nix
            ./modules/darwin/defaults/apps/com.sproutcube.shortcat.nix
            ./modules/darwin/defaults/apps/company.thebrowser.browser.nix
            ./modules/darwin/defaults/apps/com.colliderli.iina.nix
            ./modules/darwin/defaults/apps/com.apple.mail.nix
            ./modules/darwin/defaults/apps/com.apple.safari.nix
            ./modules/darwin/linux-builder.nix
            ./hosts/maxbook.nix
            home-manager.darwinModules.home-manager
            ./modules/home-manager.nix
          ];
        };
      };
    };
}
