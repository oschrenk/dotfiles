{ config, ... }:

# Homebrew global settings and taps.
# Homebrew itself must be installed first (scripts/bootstrap.sh handles this).
# darwin-rebuild switch then manages packages declaratively.
{
  homebrew = {
    enable = true;

    onActivation = {
      # Cleanup strategy for packages no longer declared here:
      #   none      — don't remove anything (safe during migration)
      #   uninstall — remove unlisted packages
      #   zap       — remove unlisted packages + associated data
      cleanup = "zap";
      # Update Homebrew on each activation
      autoUpdate = true;
      # `brew bundle install --cleanup` refuses to uninstall non-interactively
      # without `--force-cleanup`, so this is permanently required. nix-darwin
      # PR #1774 (which would have restructured this) was closed unmerged; see
      # follow-up issue nix-darwin#1787.
      extraFlags = [ "--force-cleanup" ];
      # Env vars passed to `brew bundle` during activation. Activation runs
      # under `sudo --user=$USER --set-home env ...`, and `env` strips
      # everything except vars passed explicitly here.
      extraEnv = {
        HOMEBREW_NO_ENV_HINTS = "1";
        HOMEBREW_NO_ANALYTICS = "1";
        HOMEBREW_NO_UPDATE_REPORT_NEW = "1";
        # Point brew's config dir at the XDG path instead of ~/.homebrew, so
        # the trust.json brew now manages itself (populated by the
        # `trusted = true` tap entries below) lives under ~/.config/homebrew.
        XDG_CONFIG_HOME = "/Users/${config.my.personal.username}/.config";
      };
    };

    # trusted = true marks each non-official tap as trusted in the generated
    # Brewfile, so brew bundle records it in trust.json itself (Homebrew 6
    # requires tap trust by default). Replaces the old hand-rendered trust.json.
    taps = [
      { name = "8ta4/extension"; trusted = true; } # extension (install browser extensions)
      { name = "darrylmorley/whatcable"; trusted = true; } # whatcable
      { name = "eddmann/tap"; trusted = true; } # whatsapp-cli
      { name = "IohannRabeson/tap"; trusted = true; } # tmignore-rs
      { name = "keith/formulae"; trusted = true; } # reminders-cli
      { name = "oschrenk/made"; trusted = true; } # personal casks and formulae
      { name = "oschrenk/personal"; trusted = true; } # personal casks and fonts
      { name = "txn2/tap"; trusted = true; } # kubefwd
      { name = "yapstudios/tap"; trusted = true; } # sfsym
    ];
  };
}
