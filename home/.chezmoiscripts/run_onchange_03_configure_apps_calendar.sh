#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## HELPER methods     ##
########################

source ~/.local/share/chezmoi/home/.chezmoiscripts/run_onchange_03_configure_apps__helper.sh

#######################################
# Calendar
#######################################
echo "Calendar: Days per week (default: 7)"
defaults write "com.apple.iCal" "n days of week" -int 7

# start week on (default: system setting)
# system setting = 0
# sunday = 1
# monday = 2
# ...
# saturday = 7
echo "Calendar: First day of the week (default: 0)"
defaults write com.apple.iCal "first day of week" -int 0

# scroll in week view by (default: week)
# day = 0
# week = 1
# week, stop on today = 2
echo "Calendar: Scroll in week view by (default: week)"
defaults write com.apple.iCal "scroll by weeks in week view" -integer 1

echo "Calendar: Show Week numbers"
defaults write "com.apple.iCal" "Show Week Numbers" '1'

echo "Calendar: Enable time zone support"
defaults write "com.apple.iCal" "TimeZone support enabled" '1'

# day starts at (default: 8:00)
# 06:00 = 360
# 08:00 = 480
# ...
echo "Calendar: First minute of work hours at 6:00"
defaults write com.apple.iCal "first minute of work hours" -integer 360
# day ends at (default: 18:00)
#
#    18:00 = 1080
#    20:00 = 1200
#    22:00 = 1320
# midnight = 1440
#      ...
echo "Calendar: Last minute of work hours at 18:00"
defaults write com.apple.iCal "last minute of work hours" -integer 1080

###########################################################
# Kill affected applications                              #
###########################################################

askToRestartApps "Calendar"

