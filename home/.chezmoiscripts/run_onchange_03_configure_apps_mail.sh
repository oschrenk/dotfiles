#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## HELPER methods     ##
########################

source ./run_onchange_03_configure_apps__helper.sh

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


###########################################################
# Kill affected applications                              #
###########################################################
for app in "Mail"; do
  while true; do
    read -p "Do you want to restart $app? [y/(n)]: " yn
    case $yn in
        [Yy]* ) killall "$app" > /dev/null 2>&1 ;open -a "$app"; break;;
        [Nn]* ) break;;
        * ) echo "Invalid answer; defaulting to no."; break;;
    esac
  done
done
