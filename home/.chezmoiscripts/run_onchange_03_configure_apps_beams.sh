#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## HELPER methods     ##
########################
source ~/.local/share/chezmoi/home/.chezmoiscripts/run_onchange_03_configure_apps__helper.sh

########################################
# Beams                                #
########################################

echo "Beams: Don't show app when laptop wakes"
/usr/libexec/PlistBuddy -c "Delete ':openWhenComputerWakesUp'" -c "Add ':openWhenComputerWakesUp' bool 'false'" "$HOME/Library/Containers/com.mihri.beams/Data/Library/Preferences/com.mihri.beams.plist"

########################################
# Kill affected applications           #
########################################

askToRestartApps "beams"
