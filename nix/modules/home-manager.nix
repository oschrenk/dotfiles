{ config, ... }:

{
  home-manager = {
    # use nix-darwin's pkgs, not a separate HM nixpkgs instance
    useGlobalPkgs = true;
    # install home.packages into system profile, not ~/.nix-profile
    useUserPackages = true;
    # pass username to all HM modules
    extraSpecialArgs = {
      username = config.system.primaryUser;
    };
    users.${config.system.primaryUser} = import ./home;
  };
}
