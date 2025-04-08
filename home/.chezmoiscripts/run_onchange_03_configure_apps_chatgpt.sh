#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## HELPER methods     ##
########################

source ~/.local/share/chezmoi/home/.chezmoiscripts/run_onchange_03_configure_apps__helper.sh

#######################################
# ChatGPT
#######################################

echo "ChatGPT: Don't pair with other apps"
defaults write "appPairingEnabled" "com.openai.chat" -bool false

echo "ChatGPT: Don't suggest trending searches"
defaults write "trendingSuggestionsEnabled" "com.openai.chat" -bool false

###########################################################
# Kill affected applications                              #
###########################################################

askToRestartApps "ChatGPT"
