#!/bin/sh

#######################################
# DESKTOP
#######################################

# "Requires "killall Dock" to take effect"
# Hot corners
# 0  : noop
# 2  : Mission Control
# 3  : Application Windows
# 4  : Desktop
# 5  : Start screen saver
# 6  : Disable screen saver
# 7  : Dashboard
# 10 : Put Display to sleep
# 11 : Launchpad
# 12 : Notification Center
echo "Desktop: Set Hotcorner Top Left to Mission Control"
defaults write com.apple.dock wvous-tl-corner -int 2
echo "Desktop: Set Hotcorner Top Right to Mission Control"
defaults write com.apple.dock wvous-tr-corner -int 2
echo "Desktop: Set Hotcorner Bottom Left to Desktop"
defaults write com.apple.dock wvous-bl-corner -int 4
echo "Desktop: Set Hotcorner Bottom Right to Screenshot"
defaults write com.apple.dock wvous-br-corner -int 5

###########################################################
# Kill affected applications                              #
###########################################################
for app in "Dock"; do
  echo "Restarting $app"
	killall "$app" > /dev/null 2>&1
done

exit 0
