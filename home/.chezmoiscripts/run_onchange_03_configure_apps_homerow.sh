#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## HELPER methods     ##
########################

source ~/.local/share/chezmoi/home/.chezmoiscripts/run_onchange_03_configure_apps__helper.sh

#######################################
# Homerow
#######################################

echo "Homerow: Set shortcut to ctrl+f"
defaults write "com.dexterleng.Homerow" "shortcut" '"\U2303F"'

echo "Homerow: Set search shortcut to ctrl+shift+f"
defaults write "com.dexterleng.Homerow" "search-shortcut" '"\U2303\U21e7F"'

echo "Homerow: Set scroll shortcut to ctrl+g"
defaults write "com.dexterleng.Homerow" "scroll-shortcut" '"\U2303G"'

echo "Homerow: Enable experimental support for Spotify"
defaults write "com.dexterleng.Homerow" "is-experimental-support-enabled" '1'

echo "Homerow: Hide menubar icon"
defaults write "com.dexterleng.Homerow" "NSStatusItem Visible Item-0" '0'
defaults write "com.dexterleng.Homerow" "show-menubar-icon" '0'

echo "Homerow: Disable certain apps"
defaults write "com.dexterleng.Homerow" "disabled-bundle-paths" '("/Applications/Alacritty.app",)'

###########################################################
# Kill affected applications                              #
###########################################################

askToRestartApps "Homerow"
