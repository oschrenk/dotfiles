{ ... }:

# nix-darwin has no native Siri voice options.
# CustomUserPreferences supports nested dicts so we use that.
{
  system.defaults.CustomUserPreferences = {
    "com.apple.assistant.backedup" = {
      # Siri voice: Nora, American English 4 (neural, female)
      "Output Voice" = {
        Custom = 1;
        Footprint = 0;
        Gender = 2;
        Language = "en-US";
        Name = "nora";
      };
    };
  };
}
