#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## HELPER methods     ##
########################
source ~/.local/share/chezmoi/home/.chezmoiscripts/run_onchange_03_configure_apps__helper.sh

########################################
# Beams                                #
########################################

echo "Reeder: Increase Font Size to XXL"
defaults write "com.reederapp.5.macOS" "article.font-size" '19'
defaults write "com.reederapp.5.macOS" "app.content-size-category" '5'

########################################
# Kill affected applications           #
########################################

askToRestartApps "Reeder"
