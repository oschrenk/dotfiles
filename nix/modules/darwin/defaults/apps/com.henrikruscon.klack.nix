{ ... }:

# Klack (mechanical keyboard sound) preferences
{
  system.defaults.CustomUserPreferences = {
    "com.henrikruscon.Klack" = {
      # Typing sound volume (0.0–1.0); keep it subtle
      volumeSlider = 0.035;

      # Switch/keycap sound profile
      activeSwitchSet = "oreo";

      # Suppress sounds from key-repeat / rapid events
      ignoreRapidKeyEvents = true;

      # Vary pitch per keystroke for a more natural sound
      enablePitchVariation = true;

      # Spatial audio positioning
      spatialAudio = true;

      # Tone pad position (0.0–1.0 on each axis)
      tonePadX = 0.125;
      tonePadY = 0.75;
    };
  };
}
