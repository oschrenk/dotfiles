# Identity values for the homelab hosts, duplicated from ../identity.nix on
# purpose. Duplication won over a shared flake or a dotfiles input: neither
# string is secret, they change rarely, and both alternatives couple the
# repositories this subtree exists to separate. A plain attrset rather than
# a module, so readers take it with `import` and no option plumbing.
{
  username = "oliver";
  email = "oliver.schrenk@gmail.com";
  timezone = "America/Guatemala";
  sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFZ0G3UHhaDSkbGrbopLIIrp5CRh48opdepjUQQPTJ+r";
}
