#!/bin/sh

#######################################
# SPOTLIGHT
#######################################

# Applications (APPLICATIONS)
# Calculator (MENU_EXPRESSION)
# Contacts (CONTACT)
# Conversion (MENU_CONVERSION)
# Definition (MENU_DEFINITION)
# Developer (SOURCE)
# Documents (DOCUMENTS)
# Events & Reminders (EVENT_TODO)
# Folders (DIRECTORIES)
# Fonts (FONTS)
# Images (IMAGES)
# Mail & Messages (MESSAGES)
# Movies (MOVIES)
# Music (MUSIC)
# Other (MENU_OTHER)
# PDF Documents (PDF)
# Presentations (PRESENTATIONS)
# Siri Suggestions (MENU_SPOTLIGHT_SUGGESTIONS)
# Spreadsheets (SPREADSHEETS)
# System Settings (SYSTEM_PREFS)
# Tips (TIPS)
# Websites (BOOKMARKS)
echo "Spotlight: Set defaults"
# the following approach doesn't work anymore, it breaks spotlight settings
# defaults write "com.apple.Spotlight" "orderedItems" '({enabled=1;name=APPLICATIONS;},{enabled=1;name="MENU_EXPRESSION";},{enabled=1;name=CONTACT;},{enabled=1;name="MENU_CONVERSION";},{enabled=0;name="MENU_DEFINITION";},{enabled=0;name=SOURCE;},{enabled=0;name=DOCUMENTS;},{enabled=1;name="EVENT_TODO";},{enabled=0;name=DIRECTORIES;},{enabled=0;name=FONTS;},{enabled=0;name=IMAGES;},{enabled=1;name=MESSAGES;},{enabled=0;name=MOVIES;},{enabled=0;name=MUSIC;},{enabled=0;name="MENU_OTHER";},{enabled=0;name=PDF;},{enabled=0;name=PRESENTATIONS;},{enabled=0;name="MENU_SPOTLIGHT_SUGGESTIONS";},{enabled=0;name=SPREADSHEETS;},{enabled=1;name="SYSTEM_PREFS";},{enabled=0;name=TIPS;},{enabled=0;name=BOOKMARKS;},)'
#
# maybe this works better but needs investigation
# /usr/libexec/PlistBuddy -c "Delete ':orderedItems:21:enabled'" -c "Add ':orderedItems:21:enabled' bool 'false'" "$HOME/Library/Preferences/com.apple.Spotlight.plist"

###########################################################
# Kill affected applications                              #
###########################################################
for app in "Finder" "System Preferences"; do
  echo "Restarting $app"
	killall "$app" > /dev/null 2>&1
done

exit 0
