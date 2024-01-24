#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## HELPER methods     ##
########################

source ./run_onchange_03_configure_apps__helper.sh

#######################################
# Calendar
#######################################

echo "Calendar: Show Week numbers"
defaults write "com.apple.iCal" "Show Week Numbers" '1'

echo "Calendar: Enable time zone support"
defaults write "com.apple.iCal" "TimeZone support enabled" '1'


###########################################################
# Kill affected applications                              #
###########################################################

askToRestartApps "Calendar"

