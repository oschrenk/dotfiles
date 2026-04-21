{ ... }:

# Maps preferences
# NOTE: Maps uses the com.apple.GEO domain for these preferences, not com.apple.Maps
{
  system.defaults.CustomUserPreferences = {
    "com.apple.GEO" = {
      # Show weather conditions on the map
      ClimateShowWeatherConditions = 1;

      # Hide air quality index overlay
      ClimateShowAirQualityIndex = 0;
    };
  };
}
