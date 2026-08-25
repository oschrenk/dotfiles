{ ... }:

# Homebrew packages for machines acting as a server.
# Import this module in the host file for any server machine.
{
  homebrew.brews = [
    # homebrew-core, not the personal tap — the tap formula shadowed core and
    # pinned 0.7.0 while core ships a current bottle.
    "msgvault" # cli, archive email and chat
  ];
}
