#!/bin/sh

#######################################
# FINDER
#######################################

echo "Finder: Disable the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Finder: new window location set to $HOME/Downloads. Same as Finder > Preferences > New Finder Windows show
# Computer     : `PfCm`
# Volume       : `PfVo`
# $HOME        : `PfHm`
# Desktop      : `PfDe`
# Documents    : `PfDo`
# All My Files : `PfAF`
# Other…       : `PfLo`
# eg. For $HOME use "PfHm" and "file://${HOME}/"
# eg For other path use "PfLo" and "file:///foo/bar/"
echo "Finder: Set new window location to ~/Downloads"
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/Downloads"

# Toggles menu item View > "Show/Hide Path Bar"
# Requires closing of finder windows
# Tested on macOS 12.4
echo "Finder: Show Path bar in Finder"
defaults write com.apple.finder ShowPathbar -bool true

# Hide Statusbar
# Toggles menu item View > "Show/Hide Status Bar"
# Requires closing of finder windows
# Tested on macOS 12.4
echo "Finder: Hide Status bar in Finder"
defaults write com.apple.finder 'ShowStatusBar' -bool false

# Toggles "Finder > Preferences > Advanced > "Show all filename extensions"
# Tested on macOS 12.4
# Requires 'killall Finder'"
echo "Finder: Show all filename extensions in Finder"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Set search scope.
# This Mac       : `SCev`
# Current Folder : `SCcf`
# Previous Scope : `SCsp`
# Tested on macOS 12.4
# Requires 'killall Finder'"
echo "Finder: Set search scope to current folder"
defaults write com.apple.finder FXDefaultSearchScope SCcf

# Set preferred view style.
# Icon View   : `icnv`
# List View   : `Nlsv`
# Column View : `clmv`
# Cover Flow  : `Flwv`
# Tested on macOS 12.4
# Requires deletion of ~/.DS_Store
echo "Finder: Set preferred view style to column view"
defaults write com.apple.finder FXPreferredViewStyle clmv
rm -rf ~/.DS_Store

# Set width of sidebar
# Tested on macOS 12.4
# Requires 'killall Finder'"
echo "Finder: Set sidebar width to 150"
defaults write com.apple.finder SidebarWidth -int 150

# Enable spring loading for directories
# Tested on macOS 12.5
# Requires: Nothing. Takes immediate effect
echo "Finder: Enable spring loading for directories"
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Shorten the spring loading delay for directories
# Tested on macOS 12.5
# Requires: Nothing. Takes immediate effect
echo "Finder: Shorten the spring loading delay for directories"
defaults write NSGlobalDomain com.apple.springing.delay -float 0.2



# Set Column View Options
# Tested on macOS 15.5
# Requires: Nothing. Takes immediate effect
#
# disable grouping
# Requires: Nothing. Takes immediate effect
defaults write "FXPreferredGroupBy" "com.apple.finder" 'Kind'

# View Options
# ColumnShowIcons    : Show preview column
# ShowPreview        : Show icons
# ShowIconThumbnails : Show icon preview
# ArrangeBy          : Sort by
#   dnam : Name
#   kipl : Kind
#   ludt : Date Last Opened
#   pAdd : Date Added
#   modd : Date Modified
#   ascd : Date Created
#   logs : Size
#   labl : Tags
#
# Requires: killall Finder
# Doesn't quite work. Once ColumnShowIcons it won't turn it back on
/usr/libexec/PlistBuddy \
    -c "Set :StandardViewOptions:ColumnViewOptions:ColumnShowIcons bool    true" \
    -c "Set :StandardViewOptions:ColumnViewOptions:FontSize        16"    \
    -c "Set :StandardViewOptions:ColumnViewOptions:ShowPreview     bool    true"  \
    -c "Set :StandardViewOptions:ColumnViewOptions:ArrangeBy       string  dnam"  \
    ~/Library/Preferences/com.apple.finder.plist

###########################################################
# Kill affected applications                              #
###########################################################
for app in "Finder"; do
  echo "Restarting $app"
	killall "$app" > /dev/null 2>&1
done

exit 0
