#!/bin/sh
# See https://explainshell.com/explain?cmd=set%20-eufo%20pipefail
# set -eufo pipefail

source ~/.local/share/chezmoi/home/.chezmoiscripts/run_onchange_03_configure_apps__helper.sh

#######################################
# Requirements
#######################################

SPICETIFY_BIN="spicetify"
SASS_BIN="sass"
SPICETIFY_CONFIG_PATH="$HOME/.config/spicetify"
SPICETIFY_THEMES_PATH="$SPICETIFY_CONFIG_PATH/Themes"
GRUVIFY_REPO_NAME="Gruvify"
GRUVIFY_REPO_URL="https://github.com/Skaytacium/Gruvify.git"

# check if spicetify exists
if ! command -v $SPICETIFY_BIN >/dev/null 2>&1; then
  echo "spicetify not found. Exiting"
  exit 1
fi

# check if sass exists
if ! command -v $SASS_BIN >/dev/null 2>&1; then
  echo "sass not found. Exiting"
  exit 1
fi

# check if config path exists
if [ ! -d "$SPICETIFY_CONFIG_PATH" ]; then
  echo "$SPICETIFY_CONFIG_PATH does not exist"
  exit 1
fi

#######################################
# Clone or pull
#######################################

mkdir -p "$SPICETIFY_THEMES_PATH"
cd "$SPICETIFY_THEMES_PATH" || exit 

if [ ! -d "$GRUVIFY_REPO_NAME/.git" ]; then
  echo "Cloning repository..."
  git clone "$REPO_URL" "$GRUVIFY_REPO_NAME"
else
  echo "Repository exists, pulling latest changes..."
  cd "$GRUVIFY_REPO_NAME" && git pull
fi

#######################################
# Build
#######################################

sass user.sass user.css

#######################################
# Install
#######################################

# spicetify is highly dependent on the Spotify installation
# there can be various error cases that I haven't scripted out yet

spicetify config current_theme Gruvify
spicetify apply
