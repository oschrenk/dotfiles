#!/bin/sh

# support up to 5 sessions
for id in $(seq 1 5); do
  sketchybar --add item "tmux.session.$id" left \
	  	       --set tmux.session."$id" \
		  	           script="$PLUGIN_DIR/tmux.session-2.sh" \
                   update_freq=60 \
		         --add event tmux_sessions_update \
		         --subscribe tmux.session."$id" tmux_sessions_update
done
