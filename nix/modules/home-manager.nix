{ config, arbol, infuse, meter, mission, plan, sessionizer, ... }:

{
  home-manager = {
    # use nix-darwin's pkgs, not a separate HM nixpkgs instance
    useGlobalPkgs = true;
    # install home.packages into system profile, not ~/.nix-profile
    useUserPackages = true;
    # pass username to all HM modules
    extraSpecialArgs = {
      username = config.system.primaryUser;
      inherit arbol infuse meter mission plan sessionizer;
    };
    users.${config.system.primaryUser} = import ./home;
  };
}
