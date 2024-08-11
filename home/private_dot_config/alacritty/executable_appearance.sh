#!/usr/bin/env zsh

local cmd="$1"

function setDark() {
  ln -sf gruvbox_dark.toml themes/active.toml
  touch alacritty.toml
}

function setLight() {
  ln -sf gruvbox_light.toml themes/active.toml
  touch alacritty.toml
}

if [[ "$cmd" == "toggle" ]] then
  local CURRENT_THEME=$(readlink -- themes/active.toml)
  case "$CURRENT_THEME" in
    *dark*)  setLight
      ;;
    *light*) setDark
      ;;
    *)     echo "Can't find type of file";;
  esac
elif [[ "$cmd" == "light" ]] then
  setLight
elif [[ "$cmd" == "dark" ]] then
  setDark
fi


