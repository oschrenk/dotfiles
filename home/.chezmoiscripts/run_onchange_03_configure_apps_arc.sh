#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## HELPER methods     ##
########################
source ~/.local/share/chezmoi/home/.chezmoiscripts/run_onchange_03_configure_apps__helper.sh

#######################################
# Arc Browser
#######################################

echo "Arc: Disable User interface sounds"
defaults write "company.thebrowser.Browser" "playUserInterfaceSoundsDisabled" '1'

echo "Arc: Skip unboxing video"
defaults write "company.thebrowser.Browser" "shouldSkipUnboxingVideo" '1'

###########################################################
# Kill affected applications                              #
###########################################################

askToRestartApps "Arc"
