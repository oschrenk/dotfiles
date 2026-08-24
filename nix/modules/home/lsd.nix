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

  # Deployed verbatim rather than via `programs.lsd.settings`, which renders the
  # yaml from an attrset and drops the upstream documentation comments.
  xdg.configFile."lsd/config.yaml".source = ./lsd/config.yaml;
}
