#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## HELPER methods     ##
########################

source ~/.local/share/chezmoi/home/.chezmoiscripts/run_onchange_03_configure_apps__helper.sh

#######################################
# SAFARI
#######################################

echo "Safari: Privacy: Don’t send search queries to Apple"
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

 echo "Safari: Disable Java"
defaults write com.apple.Safari WebKitJavaEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles -bool false

echo "Safari: Block pop-up windows"
defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

echo "Safari: Enable “Do Not Track"
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

echo "Safari: Update extensions automatically"
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

echo "Safari: Warn about fraudulent websites"
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

###########################################################
# Kill affected applications                              #
###########################################################

askToRestartApps "Safari"
