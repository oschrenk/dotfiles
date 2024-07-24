#!/bin/sh

# support up to 3 windows
for id in $(seq 1 5); do
  sketchybar --add item "tmux.windows.$id" left \
	  	       --set tmux.windows."$id" \
		  	           script="$PLUGIN_DIR/tmux.window.sh" \
                   update_freq=10 \
		         --add event tmux_windows_update \
		         --subscribe tmux.windows."$id" tmux_windows_update
done

