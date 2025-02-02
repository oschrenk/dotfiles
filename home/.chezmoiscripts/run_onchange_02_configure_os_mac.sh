#!/bin/sh

#######################################
# Available Sections:
#
# SPOTLIGHT
# SIRI
# SCREENSHOTS
# KEYBOARD
# TIME MACHINE
# ACCESSIBILITY
#
#######################################

#######################################
# SPOTLIGHT
#######################################

# Applications (APPLICATIONS)
# Calculator (MENU_EXPRESSION)
# Contacts (CONTACT)
# Conversion (MENU_CONVERSION)
# Definition (MENU_DEFINITION)
# Developer (SOURCE)
# Documents (DOCUMENTS)
# Events & Reminders (EVENT_TODO)
# Folders (DIRECTORIES)
# Fonts (FONTS)
# Images (IMAGES)
# Mail & Messages (MESSAGES)
# Movies (MOVIES)
# Music (MUSIC)
# Other (MENU_OTHER)
# PDF Documents (PDF)
# Presentations (PRESENTATIONS)
# Siri Suggestions (MENU_SPOTLIGHT_SUGGESTIONS)
# Spreadsheets (SPREADSHEETS)
# System Settings (SYSTEM_PREFS)
# Tips (TIPS)
# Websites (BOOKMARKS)
echo "Spotlight: Set defaults"
defaults write "com.apple.Spotlight" "orderedItems" '({enabled=1;name=APPLICATIONS;},{enabled=0;name=BOOKMARKS;},{enabled=1;name="MENU_EXPRESSION";},{enabled=1;name=CONTACT;},{enabled=0;name="MENU_CONVERSION";},{enabled=0;name="MENU_DEFINITION";},{enabled=1;name=DOCUMENTS;},{enabled=1;name="EVENT_TODO";},{enabled=1;name=DIRECTORIES;},{enabled=1;name=FONTS;},{enabled=1;name=IMAGES;},{enabled=1;name=MESSAGES;},{enabled=0;name=MOVIES;},{enabled=0;name=MUSIC;},{enabled=0;name="MENU_OTHER";},{enabled=0;name=PDF;},{enabled=0;name=PRESENTATIONS;},{enabled=0;name="MENU_SPOTLIGHT_SUGGESTIONS";},{enabled=0;name=SPREADSHEETS;},{enabled=1;name="SYSTEM_PREFS";},)'

#######################################
# SIRI
#######################################

echo "Siri: Enable Female Irish voice"
defaults write "com.apple.assistant.backedup" "Output Voice" '{Custom=1;Footprint=2;Gender=2;Language="en-IE";Name=maeve;}'

#######################################
# SCREENSHOTS
#######################################

echo "Screenshot: Save screenshots as png"
defaults write com.apple.screencapture type png

echo "Screenshot: Save screenshots to ~/Downloads"
defaults write com.apple.screencapture location ~/Downloads

#######################################
# KEYBOARD
#######################################

echo "Keyboard: Set key repeat rate to 1 (normal minimum is 2 => 30 ms)"
echo "To experiment with speeds go to https://mac-os-key-repeat.vercel.app/"
defaults write "Apple Global Domain" "KeyRepeat" '1'

echo "Keyboard: Set initial key repeat rate to 3 (normal minimum is 3 => 225ms)"
echo "To experiment with speeds go to https://mac-os-key-repeat.vercel.app/"
defaults write "Apple Global Domain" "InitialKeyRepeat" '3'

echo "Keyboard: Disable auto capitalization"
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

echo "Keyboard: Disable \"smart\" dashes"
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

echo "Keyboard: Disable automatic period substitutions"
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

echo "Keyboard: Disable smart quotes"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

echo "Keyboard: Enable keyboard navigation"
defaults write "Apple Global Domain" "AppleKeyboardUIMode" '2'

echo "Keyboard: Fn does nothing"
defaults write "com.apple.HIToolbox" "AppleFnUsageType" '0'

echo "Keyboard shortcut: Disable ^→, and ^← to switch spaces"
plutil -replace AppleSymbolicHotKeys.79.enabled -bool NO ~/Library/Preferences/com.apple.symbolichotkeys.plist
plutil -replace AppleSymbolicHotKeys.81.enabled -bool NO ~/Library/Preferences/com.apple.symbolichotkeys.plist

#######################################
# TIME MACHINE
#######################################

echo "Time Machine: Exclude directories from Time Machine backups"
tmutil addexclusion ~/Downloads
tmutil addexclusion ~/Movies

#######################################
# ACCESSIBILITY
#######################################

echo "Accessibility: Use ⌘+scroll gesture to Zoom" 
defaults write "com.apple.universalaccess" "closeViewScrollWheelToggle" '1'
defaults write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "HIDScrollZoomModifierMask" '1048576'

###########################################################
# Kill affected applications                              #
###########################################################
for app in "Dock" "Finder" "System Preferences"; do
  echo "Restarting $app"
	killall "$app" > /dev/null 2>&1
done

exit 0
