{ ... }:

# Homebrew global settings and taps.
# Homebrew itself must be installed first (bootstrap.sh handles this).
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
      # Env vars passed to `brew bundle` during activation. Activation runs
      # under sudo so user shell env is not inherited.
      extraEnv = {
        HOMEBREW_NO_ENV_HINTS = "1";
        HOMEBREW_NO_ANALYTICS = "1";
        HOMEBREW_NO_UPDATE_REPORT_NEW = "1";
      };
    };

    taps = [
      "cristianoliveira/tap" # aerospace-scratchpad
      "darrylmorley/whatcable" # whatcable
      "felixkratz/formulae" # sketchybar
      "IohannRabeson/tap" # tmignore-rs
      "johannesnagl/tap" # showmd
      "keith/formulae" # reminders-cli
      "nikitabobko/tap" # aerospace
      "oschrenk/made" # tools created by oschrenk
      "oschrenk/personal" # personal casks and fonts
      "sass/sass" # sass
      "txn2/tap" # kubefwd
      "yapstudios/tap" # sfsym
    ];
  };
}
