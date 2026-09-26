{ ... }:

# com.apple.universalaccess is TCC-protected: without Full Disk Access for the
# terminal the writes fail. The tool reports the failure and continues, unlike
# nix-darwin's own write, which aborted the whole activation.
{
  programs.nix-plist-manager.options.applications.systemSettings.accessibility = {
    zoom = {
      # ⌘+scroll gesture to zoom
      useScrollGestureWithModifierKeysToZoom = true;
      modifierKeyForScrollGesture.command = true;
    };
    display = {
      textSize = {
        preferredReadingSize = "XL";
      };
    };
  };
}
