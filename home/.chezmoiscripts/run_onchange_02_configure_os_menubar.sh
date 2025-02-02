#!/bin/sh

#######################################
# MENUBAR
#######################################

# Set Date/Time Format in Menubar like 17. Apr 17:58
echo "Menubar: Set clock to d. MMM HH:mm eg 17. Apr 17:58"
defaults write com.apple.menuextra.clock DateFormat -string "d. MMM HH:mm"

echo "Menubar: Always hide"
defaults write "Apple Global Domain" "AppleMenuBarVisibleInFullscreen" '0'

echo "Menubar: Always show WiFi"
defaults write "com.apple.controlcenter" "NSStatusItem Visible WiFi" '1'

echo "Menubar: Always show Sound"
defaults write "com.apple.controlcenter" "NSStatusItem Visible Sound" '1'

echo "Menubar: Always show FocusModes"
defaults write "com.apple.controlcenter" "NSStatusItem Visible FocusModes" '1'

echo "Menubar: Always show Battery"
defaults write "com.apple.controlcenter" "NSStatusItem Visible Battery" '1'

echo "Menubar: Never show Now Playing"
defaults write "com.apple.controlcenter" "NSStatusItem Visible NowPlaying" '0'

echo "Menubar: Don't show input source"
defaults write "com.apple.TextInputMenu" "visible" '0'

echo "Menubar: Hide Siri"
defaults write "com.apple.Siri" "StatusMenuVisible" '0'

###########################################################
# Kill affected applications                              #
###########################################################
for app in "Finder" "System Preferences"; do
  echo "Restarting $app"
	killall "$app" > /dev/null 2>&1
done

exit 0
