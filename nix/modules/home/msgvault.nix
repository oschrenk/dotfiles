# msgvault — archive email and chat. MSGVAULT_HOME is set to this directory in
# fish.nix, so it holds the database, OAuth tokens and attachments too.
# Migrated from chezmoi (home/private_dot_config/private_msgvault/).
{ lib, ... }:
{
  # The single file, never the directory: msgvault.db, tokens/ and
  # attachments/ live alongside it and a directory symlink would swallow them.
  #
  # No secret in here, only a path to client_secret.json and a rate limit, so
  # the world-readable nix store is fine. The secret itself is not in the repo.
  xdg.configFile."msgvault/config.toml".source = ./msgvault/config.toml;

  # chezmoi's private_ prefix held this at 0700 and home-manager creates
  # parents at 0755. The OAuth tokens land here, so restore the mode.
  home.activation.msgvaultConfigMode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    [ -d "$HOME/.config/msgvault" ] && chmod 700 "$HOME/.config/msgvault"
  '';
}
