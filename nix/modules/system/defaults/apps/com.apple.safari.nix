{ ... }:

# Safari preferences
{
  system.defaults.CustomUserPreferences = {
    "com.apple.Safari" = {
      # Privacy: don't send search queries to Apple
      UniversalSearchEnabled = false;
      SuppressSearchSuggestions = true;

      # Disable Java
      WebKitJavaEnabled = false;
      "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled" = false;
      "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles" = false;

      # Block pop-up windows
      WebKitJavaScriptCanOpenWindowsAutomatically = false;
      "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically" = false;

      # Send Do Not Track header
      SendDoNotTrackHTTPHeader = true;

      # Update extensions automatically
      InstallExtensionUpdatesAutomatically = true;

      # Warn about fraudulent websites
      WarnAboutFraudulentWebsites = true;
    };
  };
}
