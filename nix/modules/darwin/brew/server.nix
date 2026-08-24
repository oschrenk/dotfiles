{ ... }:

# Homebrew packages for machines acting as a server.
# Import this module in the host file for any server machine.
{
  homebrew.brews = [
    # Runtime for obsidian-headless's better-sqlite3 addon. Listed explicitly
    # because it is keg-only and brew bundle autoremoves transitive deps.
    "node@22"
    "oschrenk/personal/obsidian-headless" # cli
    # homebrew-core, not the personal tap — the tap formula shadowed core and
    # pinned 0.7.0 while core ships a current bottle.
    "msgvault" # cli, archive email and chat
  ];
}
