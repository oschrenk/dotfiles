#!/bin/sh
nvim -es -u ~/.config/nvim/plugins.vim -i NONE -c "PlugUpgrade" -c "PlugClean!" -c "PlugUpdate" -c "PlugInstall" -c "CocUpdate" -c "qa"
