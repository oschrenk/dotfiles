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
defaults write "com.sproutcube.Shortcat" "KeyboardShortcuts_toggleShortcat" '{"carbonModifiers":4096,"carbonKeyCode":3}'

###########################################################
# Kill affected applications                              #
###########################################################

askToRestartApps "Shortcat"
