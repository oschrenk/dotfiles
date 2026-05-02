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
