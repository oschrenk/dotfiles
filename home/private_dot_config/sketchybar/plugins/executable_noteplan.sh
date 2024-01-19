#!/bin/sh

OPEN=$(lsappinfo -all info -only StatusLabel "co.noteplan.NotePlan3" | sed -nr 's/\"StatusLabel\"=\{ \"label\"=\"(.+)\" \}$/\1/p')

if [[ $OPEN != "" ]]; then
  sketchybar -m --set noteplan icon=󰸞 \
                          label="$OPEN" \
                          drawing=on
else
  sketchybar -m --set noteplan icon=󰸞 \
                          label="0" \
                          drawing=on
fi
