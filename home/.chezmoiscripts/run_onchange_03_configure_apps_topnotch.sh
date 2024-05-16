#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## HELPER methods     ##
########################

source ~/.local/share/chezmoi/home/.chezmoiscripts/run_onchange_03_configure_apps__helper.sh

#######################################
# TopNotch
#######################################

echo "Top Notch: Enable"
defaults write "pl.maketheweb.TopNotch" "isEnabled" '1'

echo "Top Notch: Hide on Macbook Screen only"
defaults write "pl.maketheweb.TopNotch" "hideOnBuiltInOnly" '1'

echo "Top Notch: Hide Menubar Icon (start app again to show icon)"
defaults write "pl.maketheweb.TopNotch" "hideMenubarIcon" '1'


###########################################################
# Kill affected applications                              #
###########################################################

askToRestartApps "Homerow"
