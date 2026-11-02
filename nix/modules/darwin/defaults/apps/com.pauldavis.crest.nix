_:

# Crest (browser) preferences. The cask installs the stable build and Sparkle
# moves it to nightly from there; brew leaves it alone because of auto_updates.
{
  system.defaults.CustomUserPreferences = {
    "com.pauldavis.crest" = {
      "crest.software-update.channel" = "nightly";

      # A launch resets the channel to the build's own default whenever this
      # differs from that default, so a fresh stable install needs "stable" here
      # to keep the line above. A nightly build still ends up on nightly.
      "crest.software-update.bundled-channel" = "stable";

      # Sparkle: check and install without asking
      SUEnableAutomaticChecks = true;
      SUAutomaticallyUpdate = true;
    };
  };
}
