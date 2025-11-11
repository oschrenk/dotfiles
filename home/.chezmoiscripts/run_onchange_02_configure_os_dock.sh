#!/bin/sh

#######################################
# DOCK
#######################################

# Sets "System Preferences > Dock & Menu Bar > Dock > Automatically hide and show the Dock
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
# requires https://github.com/kcrawford/dockutil
for item in \
	Calendar \
	Contacts \
	FaceTime \
	Keynote \
	Launchpad \
	Mail \
	Maps \
	Messages \
	Music \
	News \
	Notes \
	Numbers \
	Pages \
	Photos \
	Podcasts \
	Reminders \
	Safari \
	TV \
  Freeform \
	"App Store" \
	"System Settings" \
  "Homerow" \
  "Karabiner-Elements" \
  "Neovide" \
  "Telegram" \
  ; do
  if (dockutil --find "$item" > /dev/null 2>&1); then
    echo "Dock: Unpinning $item from dock"
    dockutil --no-restart --remove "$item"
  else
    echo "Dock: $item already unpinned from dock"
  fi
done

###########################################################
# Kill affected applications                              #
###########################################################
for app in "Dock"; do
  echo "Restarting $app"
	killall "$app" > /dev/null 2>&1
done

exit 0
