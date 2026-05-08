{ ... }:
{
  programs.lsd = {
    enable = true;
    # Aliases (ls/ll/la/lt) are defined explicitly in fish.nix so we know
    # exactly what each one does. Disable HM's auto-injected ones to avoid
    # duplicate definitions and surprises (e.g. HM sets `la = lsd -A` while
    # we want `la = lsd -la`).
    enableFishIntegration = false;
  };
}
