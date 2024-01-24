#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## HELPER methods     ##
########################

source ./run_onchange_03_configure_apps__helper.sh

#######################################
# Flux
#######################################
echo "Flux: Set location to Haarlem"
defaults write "org.herf.Flux" "locationTextField" '"Haarlem"'
defaults write "org.herf.Flux" "location" '"52.38,4.63"'

echo "Flux: Set color transitions"
defaults delete "org.herf.Flux" "dayColorTemp"
defaults write "org.herf.Flux" "lateColorTemp" '1900'  # night
defaults write "org.herf.Flux" "nightColorTemp" '3200' # evening
defaults write "org.herf.Flux" "wakeTime" '390'
defaults write "org.herf.Flux" "steptime" '26'

###########################################################
# Kill affected applications                              #
###########################################################

askToRestartApps "Flux"
