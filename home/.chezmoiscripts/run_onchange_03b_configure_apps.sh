#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## DOCS   methods     ##
########################

# to find the bundle identifier, you can point to the app directory and read
# the "Info.plist"
#
# For example:
# /usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "/Applications/IINA.app/Contents/Info.plist"
# com.colliderli.iina
#
# 
# to find changes to settings, install
#
# https://github.com/catilac/plistwatch
#
# It does not catch all changes (depends on macos behaviour and app behaviour)
# but will get you far

########################
## HELPER methods     ##
########################
#
# Helps configure custom keyboard shortcuts for applications
#
# This methods ensures to add the application only ONCE to the array but only once!
# see also https://github.com/ymendel/dotfiles/issues/1
allowCustomKeyboardShortcutsForApp() {
    local appName="$1"
    if [[ $# == 0 || $# > 1 ]]; then
        echo "usage: allowCustomKeyboardShortcutsForApp com.company.appname"
        # wrong usage
        return 1
    else
        if ! ( defaults read com.apple.universalaccess "com.apple.custommenu.apps" 2>/dev/null | grep -q "$appName" )
        then
            # does not contain app, so add it
            defaults write com.apple.universalaccess "com.apple.custommenu.apps" -array-add "$appName"
        fi
    fi
}

#######################################
# KEYBOARD DOCUMENTATION
#######################################

# keyboard shortcuts
# modifier key legend:
#  @ = command
#  ^ = control
#  ~ = option
#  $ = shift
key_cmd='@'
key_ctrl='^'
key_opt='~'
key_shift='$'

# Restart cfprefsd and Finder for changes to take effect.
# You may also have to restart any apps that were running
# when you changed their keyboard shortcuts. There is some
# amount of voodoo as to what you do or do not have to
# restart, and when.

#######################################
# CHROME
#######################################

echo "Chrome: Use the system-native print preview dialog"
defaults write com.google.Chrome DisablePrintPreview -bool true

#######################################
# Arc Browser
#######################################

echo "Arc: Disable User interface sounds"
defaults write "company.thebrowser.Browser" "playUserInterfaceSoundsDisabled" '1'

echo "Arc: Skip unboxing video"
defaults write "company.thebrowser.Browser" "shouldSkipUnboxingVideo" '1'

#######################################
# HAMMERSPOON
#######################################

echo "Hammerspoon: Move config file to XDG_CONFIG_HOME"
defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

echo "Hammerspoon: Don't show in Dock"
defaults write "org.hammerspoon.Hammerspoon" "MJShowDockIconKey" '0'

echo "Hammerspoon: Don't show in Menubar"
defaults write "org.hammerspoon.Hammerspoon" "MJShowMenuIconKey" '0'

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
# Calendar
#######################################

echo "Calendar: Show Week numbers"
defaults write "com.apple.iCal" "Show Week Numbers" '1'

echo "Calendar: Enable time zone support"
defaults write "com.apple.iCal" "TimeZone support enabled" '1'

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
for app in "Chrome" "Arc" "Hammerspoon" "Mail" "Safari" "IINA" "NotePlan" "Homerow" "TopNotch" "Flux" "idea" "Calendar" "cfprefsd" "Finder"; do
  while true; do
    read -p "Do you want to restart $app? [y/(n)]: " yn
    case $yn in
        [Yy]* ) killall "$app" > /dev/null 2>&1 ;open -a "$app"; break;;
        [Nn]* ) break;;
        * ) echo "Invalid answer; defaulting to no."; break;;
    esac
  done
done