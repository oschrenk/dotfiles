{ ... }:

# The diagnostics domain is root-owned, so the setting only exists in the
# darwin module, not in home-manager.
{
  programs.nix-plist-manager.options.applications.systemSettings.privacyAndSecurity.analyticsAndImprovements = {
    shareMacAnalytics = true;
    shareWithAppDevelopers = true;
  };
}
