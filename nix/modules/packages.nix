{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (_final: prev: {
      # direnv's test suite hangs on macOS sandboxed builds
      direnv = prev.direnv.overrideAttrs (_old: { doCheck = false; });
    })
  ];

  environment.systemPackages = with pkgs; [
    direnv
    nix-direnv
  ];
}
