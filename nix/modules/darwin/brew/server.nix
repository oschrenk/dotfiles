{ ... }:

# Homebrew packages for machines acting as a server.
# Import this module in the host file for any server machine.
{
  homebrew.brews = [
    # Runtime for obsidian-headless's better-sqlite3 addon. Listed explicitly
    # because it is keg-only and brew bundle autoremoves transitive deps.
    "node@22"
    "oschrenk/personal/obsidian-headless" # cli
    "oschrenk/personal/msgvault" # cli, archive email
  ];
}
