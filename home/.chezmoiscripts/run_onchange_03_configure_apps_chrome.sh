#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## HELPER methods     ##
########################

source ./run_onchange_03_configure_apps__helper.sh

#######################################
# CHROME
#######################################

echo "Chrome: Use the system-native print preview dialog"
defaults write com.google.Chrome DisablePrintPreview -bool true

###########################################################
# Kill affected applications                              #
###########################################################

askToRestartApps "Chrome"
