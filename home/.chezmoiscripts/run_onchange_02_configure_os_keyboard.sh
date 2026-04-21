#!/bin/sh

source ~/.local/share/chezmoi/home/.chezmoiscripts/run_onchange_03_configure_apps__helper.sh

#######################################
# KEYBOARD
#######################################

# requires https://github.com/oschrenk/keyboard.swift
echo "Keyboard: Set brightness lowest, automatic and turn off after 10s"
/opt/homebrew/bin/keyboard set --auto-brightness=true --idle-dim-time=10 --brightness=0.01

echo "Keyboard shortcut: Disable ^→, and ^← to switch spaces"
plutil -replace AppleSymbolicHotKeys.79.enabled -bool NO ~/Library/Preferences/com.apple.symbolichotkeys.plist
plutil -replace AppleSymbolicHotKeys.81.enabled -bool NO ~/Library/Preferences/com.apple.symbolichotkeys.plist

#######################################
# Calendar
#######################################

echo "Calendar: Allow Calendar to have custom keyboard shortcuts"
allowCustomKeyboardShortcutsForApp "com.apple.iCal"

echo "Calendar: Replace Toggle Calendar Sidebar with ⌘S"
defaults write com.apple.iCal NSUserKeyEquivalents "{
        'Show Calender List' = '${key_cmd}s';
        'Hide Calender List' = '${key_cmd}s';
    }"

###########################################################
# Kill affected applications                              #
###########################################################

for app in "Dock" "Finder" "System Preferences"; do
  echo "Restarting $app"
  killall "$app" > /dev/null 2>&1
done

askToRestartApps "Calendar"
