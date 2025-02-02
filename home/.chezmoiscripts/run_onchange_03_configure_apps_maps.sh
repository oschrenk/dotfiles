#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## HELPER methods     ##
########################

source ~/.local/share/chezmoi/home/.chezmoiscripts/run_onchange_03_configure_apps__helper.sh

#######################################
# Maps
#######################################

echo "Maps: Show weather"
defaults write "com.apple.GEO" "ClimateShowWeatherConditions" '1'

echo "Maps: Show air quality index"
# while this is the output of plistwatch,
# it doesn't seem to take
# actually writing anything in there seems to delete the setting
defaults write "com.apple.GEO" "ClimateShowAirQualityIndex" '0'


###########################################################
# Kill affected applications                              #
###########################################################

askToRestartApps "Maps"
