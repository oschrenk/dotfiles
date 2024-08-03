#!/bin/sh

# support fixed amount of sessions
for id in $(seq 0 4); do
  sketchybar --add item "tmux.session.$id" left \
	  	       --set tmux.session."$id" \
		  	           script="$PLUGIN_DIR/tmux.session.sh" \
                   update_freq=120 \
		         --add event tmux_sessions_update \
		         --subscribe tmux.session."$id" tmux_sessions_update
done
