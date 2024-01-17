#!/bin/sh

BASEDIR="$( chezmoi source-path )/../"

#--------------------------------------
# fileicon resistant apps
#--------------------------------------
# calibre uses it's own image to load the dock item
# only for a short time it is actually using the dock's cache
# we need to also overwrite the png inside the resources to work
if [ -d "/Applications/calibre.app" ]; then
  ORIGINAL=/Applications/calibre.app/Contents/Resources/resources/images/library.png
  BACKUP=/Applications/calibre.app/Contents/Resources/resources/images/library.png.bak
  if [ -f "$BACKUP" ]; then
    # nothing to do
    echo "calibre already backed up"
  else
    sudo cp $ORIGINAL $BACKUP
  fi

  # overwrite image
  sudo cp "$BASEDIR"/assets/icons/calibre.png /Applications/calibre.app/Contents/Resources/resources/images/library.png
  # use icon
  sudo fileicon set /Applications/calibre.app "$BASEDIR"/assets/icons/calibre.icns
else
  echo "No calibre.app found"
fi

# jdownloader uses it's own image to load the dock item
# only for a short time it is actually using the dock's cache
# we need to also overwrite the png inside the resources to work
APP_DIR="$HOME/Applications/JDownloader 2"
if [ -d "$APP_DIR" ]; then
  ORIGINAL="$APP_DIR/themes/standard/org/jdownloader/images/logo/jd_logo_128_128.png"
  BACKUP="$APP_DIR/themes/standard/org/jdownloader/images/logo/jd_logo_128_128.png.bak"
  if [ -f "$BACKUP" ]; then
    # notinng to do
    echo "jdownloader already backed up"
  else
    sudo cp "$ORIGINAL" "$BACKUP"
  fi

  # overwrite image
  sudo cp "$BASEDIR/assets/icons/jdownloader.png" "$ORIGINAL"
  # use icon
  sudo fileicon set ~/Applications/JDownloader2.app/ "$BASEDIR"/assets/icons/jdownloader.icns
else
  echo "No $APP_DIR found"
  echo
  echo
  echo
fi

#--------------------------------------
# fileicon compatible
#--------------------------------------

sudo fileicon set /Applications/Alacritty.app/ "$BASEDIR"/assets/icons/alacritty.icns
sudo fileicon set /Applications/Arc.app "$BASEDIR"/assets/icons/arc.icns
sudo fileicon set /Applications/Blackmagic\ ATEM\ Switchers/ATEM\ Software\ Control.app/ "$BASEDIR"/assets/icons/atem.icns
sudo fileicon set /Applications/Docker.app "$BASEDIR"/assets/icons/docker.icns
# docker has app inside app
sudo fileicon set /Applications/Docker.app/Contents/MacOS/Docker\ Desktop.app "$BASEDIR"/assets/icons/docker.icns

sudo fileicon set /Applications/Firefox.app/ "$BASEDIR"/assets/icons/firefox.icns
# Google Chat is in user app
sudo fileicon set ~/Applications/Chrome\ Apps.localized/Google\ Chat.app "$BASEDIR"/assets/icons/google-chat.icns
sudo fileicon set /Applications/Google\ Chrome.app "$BASEDIR"/assets/icons/google-chrome.icns
# the default icon is to similar to Noteplan 3, switch to a green icon
sudo fileicon set /Applications/GoToMeeting.app/ "$BASEDIR"/assets/icons/google_meet.icns
sudo fileicon set /Applications/HandBrake.app/ "$BASEDIR"/assets/icons/handbrake.icns
sudo fileicon set /Applications/IntelliJ\ IDEA\ CE.app "$BASEDIR"/assets/icons/intellij.icns
sudo fileicon set /Applications/OpenVPN\ Connect.app "$BASEDIR"/assets/icons/open-vpn.icns
sudo fileicon set /Applications/Pulse\ Secure.app/ "$BASEDIR"/assets/icons/mozilla-vpn.icns
sudo fileicon set /Applications/Sequel\ Pro.app/ "$BASEDIR"/assets/icons/sequel-pro.icns
sudo fileicon set /Applications/Slack.app/ "$BASEDIR"/assets/icons/slack.icns
sudo fileicon set /Applications/Spotify.app/ "$BASEDIR"/assets/icons/spotify.icns
sudo fileicon set /Applications/Steam.app/ "$BASEDIR"/assets/icons/steam.icns
sudo fileicon set /Applications/Telegram.app/ "$BASEDIR"/assets/icons/telegram.icns
sudo fileicon set /Applications/The\ Hit\ List.app "$BASEDIR"/assets/icons/the-hit-list.icns
sudo fileicon set /Applications/The\ Unarchiver.app "$BASEDIR"/assets/icons/the-unarchiver.icns
sudo fileicon set /Applications/Transmission.app/ "$BASEDIR"/assets/icons/transmission.icns
sudo fileicon set /Applications/Vimac.app/ "$BASEDIR"/assets/icons/vimac.icns
sudo fileicon set /Applications/VLC.app/ "$BASEDIR"/assets/icons/vlc.icns
sudo fileicon set /Applications/zoom.us.app "$BASEDIR"/assets/icons/zoom.icns

echo "Killing Dock"
killall Dock
