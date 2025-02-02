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
defaults write "com.apple.Spotlight" "orderedItems" '({enabled=1;name=APPLICATIONS;},{enabled=0;name=BOOKMARKS;},{enabled=1;name="MENU_EXPRESSION";},{enabled=1;name=CONTACT;},{enabled=0;name="MENU_CONVERSION";},{enabled=0;name="MENU_DEFINITION";},{enabled=1;name=DOCUMENTS;},{enabled=1;name="EVENT_TODO";},{enabled=1;name=DIRECTORIES;},{enabled=1;name=FONTS;},{enabled=1;name=IMAGES;},{enabled=1;name=MESSAGES;},{enabled=0;name=MOVIES;},{enabled=0;name=MUSIC;},{enabled=0;name="MENU_OTHER";},{enabled=0;name=PDF;},{enabled=0;name=PRESENTATIONS;},{enabled=0;name="MENU_SPOTLIGHT_SUGGESTIONS";},{enabled=0;name=SPREADSHEETS;},{enabled=1;name="SYSTEM_PREFS";},)'

###########################################################
# Kill affected applications                              #
###########################################################
for app in "Finder" "System Preferences"; do
  echo "Restarting $app"
	killall "$app" > /dev/null 2>&1
done

exit 0
