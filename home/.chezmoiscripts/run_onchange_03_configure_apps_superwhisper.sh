#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## HELPER methods     ##
########################

source ~/.local/share/chezmoi/home/.chezmoiscripts/run_onchange_03_configure_apps__helper.sh

#######################################
# IINA
#######################################

echo "superwhisper: Change dir to $HOME/.local/share/superwhisper"
mkdir -p "$HOME"/.local/share/superwhisper
/usr/libexec/PlistBuddy -c "Delete ':appFolderDirectory'" -c "Add ':appFolderDirectory' string \"$HOME/.local/share\"" "$HOME/Library/Preferences/com.superduper.superwhisper.plist"

###########################################################
# Kill affected applications                              #
###########################################################

askToRestartApps "superwhisper"
