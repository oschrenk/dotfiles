#!/bin/sh

# modifier key legend: @ = command, ^ = control, ~ = option, $ = shift
key_cmd='@'

# Adds an app to the custom keyboard shortcuts allowlist (only once)
# see https://github.com/ymendel/dotfiles/issues/1
allowCustomKeyboardShortcutsForApp() {
    local appName="$1"
    if ! ( defaults read com.apple.universalaccess "com.apple.custommenu.apps" 2>/dev/null | grep -q "$appName" )
    then
        defaults write com.apple.universalaccess "com.apple.custommenu.apps" -array-add "$appName"
    fi
}

askToRestartApps() {
  for app in $*; do
    if pgrep -xq "$app"; then
      read -p "Do you want to restart $app? [y/(n)]: " yn
      case $yn in
          [Yy]* ) killall "$app" > /dev/null 2>&1; open -a "$app";;
          * ) ;;
      esac
    fi
  done
}

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
