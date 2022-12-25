#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

#######################################
# CHROME
#######################################

echo "Chrome: Use the system-native print preview dialog"
defaults write com.google.Chrome DisablePrintPreview -bool true

#######################################
# HAMMERSPOON
#######################################

echo "Hammerspoon: Move config file to XDG_CONFIG_HOME"
defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

#######################################
# MAIL
#######################################

echo "Mail: Force messages to be displayed as plain text instead of formatted (0 to reverse)"
defaults write com.apple.mail PreferPlainText -bool true

echo "Mail: Don't add invitations to iCal automatically"
defaults write com.apple.mail AddInvitationsToICalAutomatically -bool false

echo "Mail: Copy email addresses as foo@example.com instead of Foo Bar <foo@example.com> in Mail.app"
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

echo "Mail: Disable inline attachments (just show the icons)"
defaults write com.apple.mail DisableInlineAttachmentViewing -bool false

echo "Mail: Disable send and reply animations in Mail.app"
defaults write com.apple.Mail DisableReplyAnimations -bool true
defaults write com.apple.Mail DisableSendAnimations -bool true

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

#######################################
# IINA
#######################################

echo "IINA: Don't enable playback history"
defaults write "com.colliderli.iina" "recordPlaybackHistory" '0'

echo "IINA: Don't show Open Recent Menu"
defaults write "com.colliderli.iina" "recordRecentFiles" '0'

###########################################################
# Kill affected applications                              #
###########################################################
for app in "Chrome" "Hammerspoon" "Mail" "Safari" "IINA"; do
  while true; do
    read -p "Do you want to restart $app? [y/(n)]: " yn
    case $yn in
        [Yy]* ) killall "$app" > /dev/null 2>&1 ; break;;
        [Nn]* ) break;;
        * ) echo "Invalid answer; defaulting to no."; break;;
    esac
  done
done
