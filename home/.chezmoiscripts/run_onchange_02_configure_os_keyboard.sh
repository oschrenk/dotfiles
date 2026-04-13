#!/bin/sh

#######################################
# KEYBOARD
#######################################

# requires https://github.com/oschrenk/keyboard.swift
echo "Keyboard: Set brightness lowest, automatic and turn off after 10s"
/opt/homebrew/bin/keyboard set --auto-brightness=true --idle-dim-time=10 --brightness=0.01

echo "Keyboard shortcut: Disable ^→, and ^← to switch spaces"
plutil -replace AppleSymbolicHotKeys.79.enabled -bool NO ~/Library/Preferences/com.apple.symbolichotkeys.plist
plutil -replace AppleSymbolicHotKeys.81.enabled -bool NO ~/Library/Preferences/com.apple.symbolichotkeys.plist

###########################################################
# Kill affected applications                              #
###########################################################
for app in "Dock" "Finder" "System Preferences"; do
  echo "Restarting $app"
	killall "$app" > /dev/null 2>&1
done

exit 0
