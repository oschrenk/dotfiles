{ pkgs, ... }:

{
  services.containerization.enable = true;

  environment.systemPackages = [ pkgs.socktainer ];
}
