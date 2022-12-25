#!/bin/sh

#######################################
# DOCK
#######################################

# Sets "System Preferences > Dock & Menu Bar > Dock > Automatically hide and shiw the Dock
# Tested on macOS 12.4
# Requires 'killall Dock'
echo "Dock: Automatically hide"
defaults write com.apple.dock 'autohide' -bool yes

# No UI available
# Tested on macOS 12.4
# Requires 'killall Dock'
echo "Dock: Set Autohide delay to 0 seconds"
defaults write com.apple.Dock autohide-delay -float 0

# Sets "System Preferences > Dock & Menu Bar > Dock > Position on screen
# Tested on macOS 12.4
# Requires 'killall Dock'
# Position on screen: bottom
# possible values: left|bottom|right
echo "Dock: Set position to bottom"
defaults write com.apple.dock 'orientation' -string 'bottom'

# Sets "System Preferences > Dock & Menu Bar > Dock > Size
# Tested on macOS 12.4
# Requires 'killall Dock'
# Size: 56 pixels
echo "Dock: Set tilesize to 56 pixels"
defaults write com.apple.dock 'tilesize' -int 56

# Sets "System Preferences > Dock & Menu Bar > Magnification
# Tested on macOS 12.4
# Requires 'killall Dock'
echo "Dock: Disable magnification"
defaults write com.apple.dock 'magnification' -bool false

# Dock: Unpin apps from dock
for item in \
	Launchpad \
	Safari \
	Mail \
	FaceTime \
	Messages \
	Maps \
	Photos \
	Contacts \
	Calendar \
	Reminders \
	Notes \
	Music \
	Podcasts \
	TV \
	News \
	Numbers \
	Keynote \
	Pages \
	"App Store" \
	"System Preferences" ; do
  if (dockutil --find "$item" > /dev/null 2>&1); then
    echo "Dock: Unpinning $item from dock"
    dockutil --no-restart --remove "$item"
  else
    echo "Dock: $item already unpinned from dock"
  fi
done

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
echo "Finder: Show Status bar in Finder"
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

#######################################
# DESKTOP
#######################################

# "Requires "killall Dock" to take effect"
# Hot corners
# 0  : noop
# 2  : Mission Control
# 3  : Application Windows
# 4  : Desktop
# 5  : Start screen saver
# 6  : Disable screen saver
# 7  : Dashboard
# 10 : Put Display to sleep
# 11 : Launchpad
# 12 : Notification Center
echo "Desktop: Set Hotcorner Top Left to Mission Control"
defaults write com.apple.dock wvous-tl-corner -int 2
echo "Desktop: Set Hotcorner Top Right to Mission Control"
defaults write com.apple.dock wvous-tr-corner -int 2
echo "Desktop: Set Hotcorner Bottom Left to Application Windows"
defaults write com.apple.dock wvous-bl-corner -int 4
echo "Desktop: Set Hotcorner Bottom Right to Desktop"
defaults write com.apple.dock wvous-br-corner -int 12

#######################################
# MENUBAR
#######################################

# Set Date/Time Format in Menubar like 17. Apr 17:58
echo "Menubar: Set clock to d. MMM HH:mm eg 17. Apr 17:58"
defaults write com.apple.menuextra.clock DateFormat -string "d. MMM HH:mm"

echo "Always show WiFi in menubar"
defaults write "com.apple.controlcenter" "NSStatusItem Visible WiFi" '1'

echo "Always show Sound in menubar"
defaults write "com.apple.controlcenter" "NSStatusItem Visible Sound" '1'

echo "Always show FocusModes in menubar"
defaults write "com.apple.controlcenter" "NSStatusItem Visible FocusModes" '1'

echo "Always show Battery in menubar"
defaults write "com.apple.controlcenter" "NSStatusItem Visible Battery" '1'

echo "Hide Siri in menubar"
defaults write "com.apple.Siri" "StatusMenuVisible" '0'
defaults delete "com.apple.systemuiserver" "NSStatusItem Visible Siri"

#######################################
# SCREENSHOTS
#######################################

echo "Screenshot: Save screenshots as png"
defaults write com.apple.screencapture type png

echo "Screenshot: Save screenshots to ~/Downloads"
defaults write com.apple.screencapture location ~/Downloads

#######################################
# KEYBOARD
#######################################

echo "Keyboard: Set key repeat rate to 1"
defaults write NSGlobalDomain KeyRepeat -int 1

echo "Keyboard: Set initial key repeat rate to 12"
defaults write NSGlobalDomain InitialKeyRepeat -int 12

echo "Keyboard: Disable auto capitalization"
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

echo "Keyboard: Disable \"smart\" dashes"
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

echo "Keyboard: Disable automatic period substitutions"
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

echo "Keyboard: Disable smart quotes"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

#######################################
# TIME MACHINE
#######################################

echo "Time Machine: Exclude directories from Time Machine backups"
tmutil addexclusion ~/Downloads
tmutil addexclusion ~/Movies

###########################################################
# Kill affected applications                              #
###########################################################
for app in "Dock" "Finder" "System Preferences"; do
  echo "Restarting $app"
	killall "$app" > /dev/null 2>&1
done

exit 0
