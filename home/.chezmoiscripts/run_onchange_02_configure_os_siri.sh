#!/bin/sh

#######################################
# SIRI
#######################################

echo "Siri: Enable Female Irish voice"
defaults write "com.apple.assistant.backedup" "Output Voice" '{Custom=1;Footprint=2;Gender=2;Language="en-IE";Name=maeve;}'

###########################################################
# Kill affected applications                              #
###########################################################
for app in "System Preferences"; do
  echo "Restarting $app"
	killall "$app" > /dev/null 2>&1
done

exit 0
