#!/bin/bash

# Get the current session, window, and pane
current_session=$(tmux display-message -p '#S')
current_window=$(tmux display-message -p '#I')
current_pane=$(tmux display-message -p '#D')

# Get list of all pane IDs in the current window
pane_ids=$(tmux list-panes -t "${current_session}:${current_window}" -F '#{pane_id}')

# Loop through each pane and collect directories
for pane_id in $pane_ids; do
    # Get the current working directory of the pane
    tmux display-message -p -t "$pane_id" '#{pane_current_path}'
done | sort -u
