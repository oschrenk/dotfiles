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
defaults write "co.noteplan.NotePlan3" "fontDelta" '6'
defaults write "co.noteplan.NotePlan3" "fontSize" '22'

echo "NotePlan: Set font to System"
defaults write "co.noteplan.NotePlan3" "fontFamily" 'System'

echo "NotePlan: Set text width to 700"
defaults write "co.noteplan.NotePlan3" "maxTextWidth" '700'

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
for app in "NotePlan" "cfprefsd" "Finder"; do
  while true; do
    read -p "Do you want to restart $app? [y/(n)]: " yn
    case $yn in
        [Yy]* ) killall "$app" > /dev/null 2>&1 ;open -a "$app"; break;;
        [Nn]* ) break;;
        * ) echo "Invalid answer; defaulting to no."; break;;
    esac
  done
done