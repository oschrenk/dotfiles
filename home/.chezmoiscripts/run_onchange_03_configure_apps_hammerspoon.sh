#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## HELPER methods     ##
########################

source ./run_onchange_03_configure_apps__helper.sh

#######################################
# HAMMERSPOON
#######################################

echo "Hammerspoon: Move config file to XDG_CONFIG_HOME"
defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

echo "Hammerspoon: Don't show in Dock"
defaults write "org.hammerspoon.Hammerspoon" "MJShowDockIconKey" '0'

echo "Hammerspoon: Don't show in Menubar"
defaults write "org.hammerspoon.Hammerspoon" "MJShowMenuIconKey" '0'

###########################################################
# Kill affected applications                              #
###########################################################
for app in "Hammerspoon"; do
  while true; do
    read -p "Do you want to restart $app? [y/(n)]: " yn
    case $yn in
        [Yy]* ) killall "$app" > /dev/null 2>&1 ;open -a "$app"; break;;
        [Nn]* ) break;;
        * ) echo "Invalid answer; defaulting to no."; break;;
    esac
  done
done
