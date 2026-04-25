{ ... }:

# Shortcat preferences
# NOTE: requires "Settings > Keyboard > Keyboard Shortcuts > Windows > General > Fill"
# to be deselected, otherwise Ctrl+F is taken by the system.
{
  system.defaults.CustomUserPreferences = {
    "com.sproutcube.Shortcat" = {
      # Toggle shortcut: Ctrl+F (carbonKeyCode 3 = F, carbonModifiers 4096 = Ctrl)
      "KeyboardShortcuts_toggleShortcat" = ''{"carbonModifiers":4096,"carbonKeyCode":3}'';
    };
  };
}
