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
    opnix.url = "github:brizzbuzz/opnix";
    # Own tools. Deliberately NOT following our nixpkgs: each builds against the
    # nixpkgs it locked, which is the build oschrenk.cachix.org actually holds
    # (trusted in modules/darwin/nix.nix). Adding `follows` rebases them onto our
    # nixpkgs, changes the derivation hash and turns every rebuild into a Go
    # compile. Their home-manager modules still evaluate against our pkgs, since
    # home-manager is configured with useGlobalPkgs.
    arbol.url = "github:oschrenk/arbol";
    cutter.url = "github:oschrenk/cutter";
    infuse.url = "github:oschrenk/infuse";
    meter.url = "github:oschrenk/meter";
    mission.url = "github:oschrenk/mission";
    plan.url = "github:oschrenk/plan.swift";
    sessionizer.url = "github:oschrenk/sessionizer";
    thaw.url = "github:oschrenk/thaw";
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      opnix,
      ...
    }@inputs:
    {
      # Official Nix formatter: https://github.com/NixOS/nixfmt
      # nixfmt-rfc-style in nixpkgs is the same tool, just a confusing alias
      # Run with: nix fmt
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;

      # Unit tests. Run with `task nix:test`, which builds this alone rather
      # than `nix flake check`, since that evaluates all six host configs first.
      checks.aarch64-darwin.secrets =
        let
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          failures = import ./tests/secrets.nix { inherit (pkgs) lib; };
        in
        if failures == [ ] then
          pkgs.runCommand "secrets-tests-passed" { } "touch $out"
        else
          throw "secrets catalogue tests failed:\n${builtins.toJSON failures}";


      darwinConfigurations = {
        "Olivers-MaxBook" = nix-darwin.lib.darwinSystem {
          specialArgs = inputs;
          modules = [
            ./identity.nix
            ./options.nix
            ./modules/common.nix
            ./modules/darwin/nix.nix
            ./modules/packages.nix
            opnix.darwinModules.default
            ./modules/darwin/secrets.nix
            ./modules/darwin/brew/settings.nix
            ./modules/shell.nix
            ./modules/darwin/defaults/system/accessibility.nix
            ./modules/darwin/defaults/system/desktop.nix
            ./modules/darwin/defaults/system/dock.nix
            ./modules/darwin/defaults/system/finder.nix
            ./modules/darwin/defaults/system/hotkeys.nix
            ./modules/darwin/defaults/system/keyboard.nix
            ./modules/darwin/defaults/system/loginwindow.nix
            ./modules/darwin/defaults/system/menubar.nix
            ./modules/darwin/defaults/system/screenshots.nix
            ./modules/darwin/defaults/system/siri.nix
            ./modules/darwin/defaults/system/spotlight.nix
            ./modules/darwin/defaults/system/timemachine.nix
            ./modules/darwin/defaults/apps/com.apple.ical.nix
            ./modules/darwin/defaults/apps/com.apple.maps.nix
            ./modules/darwin/defaults/apps/com.reederapp.5.macos.nix
            ./modules/darwin/defaults/apps/com.jetbrains.intellij.nix
            ./modules/darwin/defaults/apps/com.nordvpn.nordvpn.nix
            ./modules/darwin/defaults/apps/com.sproutcube.shortcat.nix
            ./modules/darwin/defaults/apps/company.thebrowser.browser.nix
            ./modules/darwin/defaults/apps/com.colliderli.iina.nix
            ./modules/darwin/defaults/apps/com.apple.mail.nix
            ./modules/darwin/defaults/apps/com.apple.safari.nix
            ./modules/darwin/defaults/apps/com.henrikruscon.klack.nix
            ./modules/darwin/defaults/apps/io.tailscale.ipn.macsys.nix
            ./modules/darwin/java.nix
            ./hosts/maxbook.nix
            home-manager.darwinModules.home-manager
            ./modules/home-manager.nix
          ];
        };

        "Olivers-AirBook" = nix-darwin.lib.darwinSystem {
          specialArgs = inputs;
          modules = [
            ./identity.nix
            ./options.nix
            ./modules/common.nix
            ./modules/darwin/nix.nix
            ./modules/packages.nix
            opnix.darwinModules.default
            ./modules/darwin/secrets.nix
            ./modules/darwin/brew/settings.nix
            ./modules/shell.nix
            ./modules/darwin/defaults/system/accessibility.nix
            ./modules/darwin/defaults/system/desktop.nix
            ./modules/darwin/defaults/system/dock.nix
            ./modules/darwin/defaults/system/finder.nix
            ./modules/darwin/defaults/system/hotkeys.nix
            ./modules/darwin/defaults/system/keyboard.nix
            ./modules/darwin/defaults/system/loginwindow.nix
            ./modules/darwin/defaults/system/menubar.nix
            ./modules/darwin/defaults/system/screenshots.nix
            ./modules/darwin/defaults/system/siri.nix
            ./modules/darwin/defaults/system/spotlight.nix
            ./modules/darwin/defaults/system/timemachine.nix
            ./modules/darwin/defaults/apps/com.apple.ical.nix
            ./modules/darwin/defaults/apps/com.apple.maps.nix
            ./modules/darwin/defaults/apps/com.reederapp.5.macos.nix
            ./modules/darwin/defaults/apps/com.jetbrains.intellij.nix
            ./modules/darwin/defaults/apps/com.nordvpn.nordvpn.nix
            ./modules/darwin/defaults/apps/com.sproutcube.shortcat.nix
            ./modules/darwin/defaults/apps/company.thebrowser.browser.nix
            ./modules/darwin/defaults/apps/com.colliderli.iina.nix
            ./modules/darwin/defaults/apps/com.apple.mail.nix
            ./modules/darwin/defaults/apps/com.apple.safari.nix
            ./modules/darwin/defaults/apps/com.henrikruscon.klack.nix
            ./modules/darwin/defaults/apps/io.tailscale.ipn.macsys.nix
            ./modules/darwin/java.nix
            ./hosts/airbook.nix
            home-manager.darwinModules.home-manager
            ./modules/home-manager.nix
          ];
        };
      };
    };
}
