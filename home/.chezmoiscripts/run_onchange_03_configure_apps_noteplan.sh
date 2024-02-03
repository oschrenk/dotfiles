#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## HELPER methods     ##
########################

source ./run_onchange_03_configure_apps__helper.sh

#######################################
# Note Plan 3
#######################################

echo "NotePlan: Set Monday as first day of the week"
defaults write "co.noteplan.NotePlan3" "firstDayOfWeek" '2'

echo "NotePlan: Enable Weekly Notes"
defaults write "co.noteplan.NotePlan3" "isWeeklyNotes" '1'

echo "NotePlan: Enable Monthly Notes"
defaults write "co.noteplan.NotePlan3" "isMonthlyNotes" '1'

echo "NotePlan: Distable Quarterly Notes"
defaults write "co.noteplan.NotePlan3" "isQuarterlyNotes" '0'

echo "NotePlan: Enable Yearly Notes"
defaults write "co.noteplan.NotePlan3" "isYearlyNotes" '1'

echo "NotePlan: Set font size to 22"
/usr/libexec/PlistBuddy -c "Delete ':fontDelta'" -c "Add ':fontDelta' integer '6'" "$HOME/Library/Containers/co.noteplan.NotePlan3/Data/Library/Preferences/co.noteplan.NotePlan3.plist"
/usr/libexec/PlistBuddy -c "Delete ':fontSize'" -c "Add ':fontSize' real '22.000000'" "$HOME/Library/Containers/co.noteplan.NotePlan3/Data/Library/Preferences/co.noteplan.NotePlan3.plist"

echo "NotePlan: Set font to System"
defaults write "co.noteplan.NotePlan3" "fontFamily" 'System'

echo "NotePlan: Set text width to 700"
/usr/libexec/PlistBuddy -c "Delete ':maxTextWidth'" -c "Add ':maxTextWidth' real '800.000000'" "$HOME/Library/Containers/co.noteplan.NotePlan3/Data/Library/Preferences/co.noteplan.NotePlan3.plist"

echo "NotePlan: Set theme to Gruvbox iA.json"
defaults write "co.noteplan.NotePlan3" "themeDark" '"Gruvbox iA.json"'

echo "NotePlan: Allow NotePlan to have custom keyboard shortcuts"
allowCustomKeyboardShortcutsForApp "co.noteplan.NotePlan3"

echo "NotePlan: Replace Toggle Sidebar shortcut to ⌘S"
echo "NotePlan: Replace Toggle Calendar Sidebar shortcut to ⇧⌘S"
defaults write co.noteplan.NotePlan3 NSUserKeyEquivalents "{
        'Toggle Sidebar' = '${key_cmd}s';
        'Toggle Calendar Sidebar' = '${key_shift}${key_cmd}s';
    }"

echo "Noteplan: Recognize Asterisk as Todo"
defaults write "co.noteplan.NotePlan3" "isAsteriskTodo" '1'

echo "Noteplan: Do not recognize Dash as Todo"
defaults write "co.noteplan.NotePlan3" "isDashTodo" '0'

###########################################################
# Kill affected applications                              #
###########################################################
# 
# Restarting cfprefsd and Finder to make keyboard changes stick
askToRestartApps "Noteplan" "Finder"
killProcess "cfprefsd"

