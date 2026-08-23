{ ... }:

# Tailscale (standalone macsys build) preferences
{
  system.defaults.CustomUserPreferences = {
    "io.tailscale.ipn.macsys" = {
      # Menu bar only; keep the Dock clear
      HideDockIcon = true;

      # Connect automatically at login
      TailscaleStartOnLogin = true;
    };
  };
}
