{ ... }:

# Homebrew packages for machines acting as a server.
# Import this module in the host file for any server machine.
{
  homebrew.brews = [
    "oschrenk/personal/obsidian-headless" # cli
    "oschrenk/personal/msgvault" # cli, archive email
  ];
}
