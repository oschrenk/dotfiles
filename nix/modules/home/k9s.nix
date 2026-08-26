# k9s — kubernetes TUI. The binary comes from a project devShell, not from
# here, so this module is config only.
# Migrated from chezmoi (home/private_dot_config/private_k9s/).
{ lib, ... }:
{
  # Declared file by file. k9s owns the rest of ~/.config/k9s: clusters/ holds
  # the per-context config it rewrites on exit, and benchmarks/ and
  # screen-dumps/ are output directories.
  #
  # The old `k9s.clusters.<name>` block is gone from config.yaml. It is not a
  # field in the current schema, so k9s ignored it, and the per-context file
  # under clusters/ is what actually applies.
  xdg.configFile."k9s/config.yaml".source = ./k9s/config.yaml;
  xdg.configFile."k9s/aliases.yaml".source = ./k9s/aliases.yaml;

  # chezmoi's private_ prefix held this at 0700; home-manager creates parents
  # at 0755.
  home.activation.k9sConfigMode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    [ -d "$HOME/.config/k9s" ] && chmod 700 "$HOME/.config/k9s"
  '';
}
