{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    direnv
    nix-direnv
  ];
}
