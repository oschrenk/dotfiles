{ osConfig, lib, pkgs, ... }:
let
  identityToml = pkgs.writeText "identity.toml" ''
    name = "${osConfig.my.personal.name}"

    [personal]
    email = "${osConfig.my.personal.email}"

    [work]
    email = "${osConfig.my.work.email}"
  '';
in
{
  home.activation.identityFile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p $HOME/.local/share/identity
    $DRY_RUN_CMD install -m 0400 ${identityToml} $HOME/.local/share/identity/data.toml
  '';
}
