#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## HELPER methods     ##
########################

source ~/.local/share/chezmoi/home/.chezmoiscripts/run_onchange_03_configure_apps__helper.sh

#######################################
# Nord VPN                            #
#######################################

echo "Nord VPN: Show Icon in menubar"
defaults write "com.nordvpn.NordVPN" "appIcon" '1'

#######################################
# Kill affected applications          #
#######################################

askToRestartApps "NordVPN"

