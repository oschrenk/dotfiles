#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## HELPER methods     ##
########################

source ./run_onchange_03_configure_apps__helper.sh

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
for app in "Arc"; do
  while true; do
    read -p "Do you want to restart $app? [y/(n)]: " yn
    case $yn in
        [Yy]* ) killall "$app" > /dev/null 2>&1 ;open -a "$app"; break;;
        [Nn]* ) break;;
        * ) echo "Invalid answer; defaulting to no."; break;;
    esac
  done
done