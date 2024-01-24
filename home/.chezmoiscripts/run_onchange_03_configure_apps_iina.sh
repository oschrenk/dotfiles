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

echo "IINA: Don't autoplay next item"
defaults write "com.colliderli.iina" "playlistAutoPlayNext" '0'

###########################################################
# Kill affected applications                              #
###########################################################

askToRestartApps "IINA"
