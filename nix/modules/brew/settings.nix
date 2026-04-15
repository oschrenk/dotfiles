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
    };

    taps = [
      "oschrenk/made" # tools created by oschrenk
      "oschrenk/personal" # personal casks and fonts
      "nikitabobko/tap" # aerospace
      "felixkratz/formulae" # sketchybar
      "cristianoliveira/tap" # aerospace-scratchpad
      "keith/formulae" # reminders-cli
      "sass/sass" # sass
      "txn2/tap" # kubefwd
    ];
  };
}
