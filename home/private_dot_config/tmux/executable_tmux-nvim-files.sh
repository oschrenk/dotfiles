#!/bin/bash

# Get the current session and window
current_session=$(tmux display-message -p '#S')
current_window=$(tmux display-message -p '#I')

# Get list of all pane IDs in the current window
pane_ids=$(tmux list-panes -t "${current_session}:${current_window}" -F '#{pane_id}')

# Loop through each pane and check for neovim instances
for pane_id in $pane_ids; do
    # Get the PID of the process in this pane
    pane_pid=$(tmux display-message -p -t "$pane_id" '#{pane_pid}')

    # Find all nvim processes that are descendants of this pane
    # We need to recursively search because nvim spawns child processes
    all_descendants=$(pgrep -P "$pane_pid" 2>/dev/null)
    nvim_pids=""

    # Check the pane itself
    pane_command=$(ps -p "$pane_pid" -o comm= 2>/dev/null)
    if [[ "$pane_command" == "nvim" ]]; then
        nvim_pids="$pane_pid"
    fi

    # Check all descendants recursively
    for desc_pid in $all_descendants; do
        desc_command=$(ps -p "$desc_pid" -o comm= 2>/dev/null)
        if [[ "$desc_command" == "nvim" ]]; then
            nvim_pids="$nvim_pids $desc_pid"
            # Also check children of this nvim process
            nvim_children=$(pgrep -P "$desc_pid" "nvim" 2>/dev/null)
            nvim_pids="$nvim_pids $nvim_children"
        fi
    done

    # For each nvim process, try to find its socket and query current buffer
    for nvim_pid in $nvim_pids; do
        # Look for socket files in /var/folders and /tmp
        nvim_socket=$(find /var/folders /tmp -name "nvim.${nvim_pid}.*" -type s 2>/dev/null | head -n 1)

        # If we found a socket, query the current buffer
        if [[ -n "$nvim_socket" ]]; then
            current_file=$(nvim --server "$nvim_socket" --headless --remote-expr "expand('%:p')" 2>/dev/null | cat)

            # Only print if we got a valid file path
            if [[ -n "$current_file" ]] && [[ -f "$current_file" ]]; then
                echo "$current_file"
            fi
        fi
    done
done | sort -u
