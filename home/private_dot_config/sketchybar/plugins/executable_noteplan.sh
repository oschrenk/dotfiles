#!/bin/sh

# requires
#   https://github.com/oschrenk/noteplan
#   https://github.com/jqlang/jq 
OPEN=$("$HOME"/Frameworks/go/bin/noteplan todo --json | jq .day.open)

if [[ $OPEN != "" ]]; then
  sketchybar -m --set noteplan icon=󰸞 \
                          label="$OPEN" \
                          drawing=on
else
  sketchybar -m --set noteplan icon=󰸞 \
                          label="0" \
                          drawing=on
fi
