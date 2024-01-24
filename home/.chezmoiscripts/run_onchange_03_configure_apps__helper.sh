#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

########################
## DOCS               ##
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

