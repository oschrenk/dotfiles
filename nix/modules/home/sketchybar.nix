{ pkgs, ... }:

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
}
