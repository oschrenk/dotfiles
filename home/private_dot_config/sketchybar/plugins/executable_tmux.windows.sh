#!/bin/sh

ITER=0
for window in $(tmux list-windows -F '#{window_name}' ); do
  sketchybar --add item "tmux.windows.$ITER" left \
	  	       --set tmux.windows."$ITER" \
		  	           script="$PLUGIN_DIR/tmux.window.sh" \
                   update_freq=120 \
		         --add event tmux_session_update \
		         --subscribe tmux.windows."$ITER" tmux_session_update
  ITER=$(expr "$ITER" + 1)
done

