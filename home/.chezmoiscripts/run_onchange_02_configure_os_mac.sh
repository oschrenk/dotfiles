#!/bin/sh

#######################################
# ACCESSIBILITY
#######################################

echo "Accessibility: Use ⌘+scroll gesture to Zoom" 
defaults write "com.apple.universalaccess" "closeViewScrollWheelToggle" '1'
defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "HIDScrollZoomModifierMask" '1048576'

###########################################################
# Kill affected applications                              #
###########################################################
for app in "System Preferences"; do
  echo "Restarting $app"
	killall "$app" > /dev/null 2>&1
done

exit 0
