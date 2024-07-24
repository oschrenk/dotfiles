#!/bin/sh

window_name="$NAME"
window_number=$(echo "$NAME" | cut -d '.' -f3)

echo "HEL $NAME" >> ~/Downloads/log.txt 

sketchybar --set "$NAME" \
	  		     icon.drawing=on \
             label.drawing="off" \
             label.font="SFMono Nerd Font:Medium:15.0" \
             drawing=off \
             icon="$window_number" 

