{ config, pkgs, ... }:

{
  programs.sketchybar = {
    enable = true;
    configType = "lua";
    sbarLuaPackage = pkgs.sbarlua;
    extraLuaPackages = ps: [
      (ps.buildLuarocksPackage rec {
        pname = "lua-tz";
        version = "1.0.0-1";
        knownRockspec = (pkgs.fetchurl {
          url = "https://luarocks.org/manifests/anaef/lua-tz-1.0.0-1.rockspec";
          hash = "sha256-JGvvv+gxVLIY2aWPzx4M4Q4OI4ri3I0/m8+1lUS775I=";
        }).outPath;
        src = pkgs.fetchFromGitHub {
          owner = "anaef";
          repo = "lua-tz";
          rev = "v1.0.0";
          hash = "sha256-QfU6KyKc21mEu/RqrZ4kwuNaOQCcKbvX4qrBYsWT6LY=";
        };
      })
    ];
    # config is left at its default of null — Nix Home Manager does not write
    # to ~/.config/sketchybar; chezmoi continues to manage the lua sources.
  };

  # launchd's default PATH is /usr/bin:/bin:/usr/sbin:/sbin, which excludes the
  # nix profiles. sketchybar's lua shells out to binaries that live there, so
  # without this those items render empty:
  #   services/Aerospace.lua  bare `aerospace`  (/run/current-system/sw/bin)
  #   services/Focus.lua      bare `mission`    (per-user profile)
  #   services/Mission.lua    bare `mission`
  #   items/Project.lua       bare `mission`
  # Sessionizer.lua and its tlink call use absolute paths and don't need this.
  launchd.agents.sketchybar.config.EnvironmentVariables = {
    PATH = "/etc/profiles/per-user/${config.home.username}/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin";
  };
}
