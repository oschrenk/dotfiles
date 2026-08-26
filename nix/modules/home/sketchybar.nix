{ config, osConfig, pkgs, ... }:

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
    # config stays null: home-manager does not write ~/.config/sketchybar. The
    # lua tree is symlinked in below instead.
  };

  # Out of the store, into the working copy, so editing a lua file and running
  # `sketchybar --reload` takes effect without a rebuild. A store symlink would
  # be read-only and would need a rebuild per edit, which is the wrong trade for
  # a config that is tuned by fiddling.
  #
  # sketchybar execs sketchybarrc, so its executable bit has to live in git
  # rather than being applied at deploy time the way chezmoi's executable_
  # prefix did.
  home.file.".config/sketchybar".source =
    config.lib.file.mkOutOfStoreSymlink "${osConfig.my.personal.dotfiles}/config/sketchybar";

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
