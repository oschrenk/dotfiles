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

#######################################
# IntelliJ Idea CE
#######################################
echo "IntelliJ Idea CE: Enable key repeat"
defaults write com.jetbrains.intellij.ce ApplePressAndHoldEnabled -bool false

###########################################################
# Kill affected applications                              #
###########################################################
# Restarting cfprefsd and Finder to make keyboard changes stick
for app in "Flux" "idea" "cfprefsd" "Finder"; do
  while true; do
    read -p "Do you want to restart $app? [y/(n)]: " yn
    case $yn in
        [Yy]* ) killall "$app" > /dev/null 2>&1 ;open -a "$app"; break;;
        [Nn]* ) break;;
        * ) echo "Invalid answer; defaulting to no."; break;;
    esac
  done
done
