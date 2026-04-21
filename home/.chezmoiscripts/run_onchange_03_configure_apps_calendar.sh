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

echo "Calendar: Allow Calendar to have custom keyboard shortcuts"
allowCustomKeyboardShortcutsForApp "com.apple.iCal"

echo "Calendar: Replace Toggle Calendar Sidebar with ⌘S"
defaults write com.apple.iCal NSUserKeyEquivalents "{
        'Show Calender List' = '${key_cmd}s';
        'Hide Calender List' = '${key_cmd}s';
    }"

###########################################################
# Kill affected applications                              #
###########################################################

askToRestartApps "Calendar"
