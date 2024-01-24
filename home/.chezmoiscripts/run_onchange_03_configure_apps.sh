#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## HELPER methods     ##
########################

source ./run_onchange_03_configure_apps__helper.sh

#######################################
# IINA
#######################################

echo "IINA: Don't enable playback history"
defaults write "com.colliderli.iina" "recordPlaybackHistory" '0'

echo "IINA: Don't show Open Recent Menu"
defaults write "com.colliderli.iina" "recordRecentFiles" '0'

echo "IINA: UI arrows rewind/forward"
defaults write "com.colliderli.iina" "arrowBtnAction" '2'

echo "IINA: Don't keep window open after playback"
defaults write "com.colliderli.iina" "keepOpenOnFileEnd" '0'

echo "IINA: Resume last playback position"
defaults delete "com.colliderli.iina" "resumeLastPosition"

echo "IINA: Don't open new windows"
defaults write "com.colliderli.iina" "alwaysOpenInNewWindow" '0'

echo "IINA: Quite after closing window"
defaults write "com.colliderli.iina" "quitWhenNoOpenedWindow" '1'

echo "IINA: Enable yt-dlp"
defaults delete "com.colliderli.iina" "ytdlEnabled"
defaults write "com.colliderli.iina" "ytdlSearchPath" '"/opt/homebrew/bin/yt-dlp"'

#######################################
# Homerow
#######################################

echo "Homerow: Set shortcut to ctrl+f"
defaults write "com.dexterleng.Homerow" "shortcut" '"\U2303F"'

echo "Homerow: Set search shortcut to ctrl+shift+f"
defaults write "com.dexterleng.Homerow" "search-shortcut" '"\U2303\U21e7F"'

echo "Homerow: Set scroll shortcut to ctrl+g"
defaults write "com.dexterleng.Homerow" "scroll-shortcut" '"\U2303G"'

echo "Homerow: Enable experimental support for Spotify"
defaults write "com.dexterleng.Homerow" "is-experimental-support-enabled" '1'

echo "Homerow: Hide menubar icon"
defaults write "com.dexterleng.Homerow" "NSStatusItem Visible Item-0" '0'
defaults write "com.dexterleng.Homerow" "show-menubar-icon" '0'

echo "Homerow: Disable certain apps"
defaults write "com.dexterleng.Homerow" "disabled-bundle-paths" '("/Applications/Alacritty.app",)'

#######################################
# TopNotch
#######################################
echo "Top Notch: Enable"
defaults write "pl.maketheweb.TopNotch" "isEnabled" '1'

echo "Top Notch: Hide on Macbook Screen only"
defaults write "pl.maketheweb.TopNotch" "hideOnBuiltInOnly" '1'

echo "Top Notch: Hide Menubar Icon (start app again to show icon)"
defaults write "pl.maketheweb.TopNotch" "hideMenubarIcon" '1'

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
for app in "IINA" "Homerow" "TopNotch" "Flux" "idea" "cfprefsd" "Finder"; do
  while true; do
    read -p "Do you want to restart $app? [y/(n)]: " yn
    case $yn in
        [Yy]* ) killall "$app" > /dev/null 2>&1 ;open -a "$app"; break;;
        [Nn]* ) break;;
        * ) echo "Invalid answer; defaulting to no."; break;;
    esac
  done
done
