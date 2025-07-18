#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## HELPER methods     ##
########################

source ~/.local/share/chezmoi/home/.chezmoiscripts/run_onchange_03_configure_apps__helper.sh

#######################################
# shortcat
#######################################

echo "shortcat: Use Ctrl+F"
echo "requires \"Settings > Keyboard > Keyboard Shortcuts > Windows > General > Fill\" to be deselected"
/usr/libexec/PlistBuddy -c "Delete ':KeyboardShortcuts_toggleShortcat'" -c "Add ':KeyboardShortcuts_toggleShortcat' string '{"carbonModifiers":4096,"carbonKeyCode":3}'" "$HOME/Library/Preferences/com.sproutcube.Shortcat.plist"

###########################################################
# Kill affected applications                              #
###########################################################

askToRestartApps "IINA"
