#!/bin/sh

# support up to 5 windows
for id in $(seq 1 5); do
  sketchybar --add item "tmux.window.$id" left \
	  	       --set tmux.window."$id" \
		  	           script="$PLUGIN_DIR/tmux.window.sh" \
                   update_freq=60 \
		         --add event tmux_windows_update \
		         --subscribe tmux.window."$id" tmux_windows_update
done

