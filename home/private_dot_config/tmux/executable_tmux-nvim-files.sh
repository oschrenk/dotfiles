#!/bin/bash

# --- your existing logic, unchanged ---
current_session=$(tmux display-message -p '#S')
current_window=$(tmux display-message -p '#I')

pane_ids=$(tmux list-panes -t "${current_session}:${current_window}" -F '#{pane_id}')
results=()

for pane_id in $pane_ids; do
    pane_pid=$(tmux display-message -p -t "$pane_id" '#{pane_pid}')
    all_descendants=$(pgrep -P "$pane_pid" 2>/dev/null)
    nvim_pids=""

    pane_command=$(ps -p "$pane_pid" -o comm= 2>/dev/null)
    [[ "$pane_command" == "nvim" ]] && nvim_pids="$pane_pid"

    for desc_pid in $all_descendants; do
        desc_command=$(ps -p "$desc_pid" -o comm= 2>/dev/null)
        if [[ "$desc_command" == "nvim" ]]; then
            nvim_pids="$nvim_pids $desc_pid"
            nvim_children=$(pgrep -P "$desc_pid" "nvim" 2>/dev/null)
            nvim_pids="$nvim_pids $nvim_children"
        fi
    done

    for nvim_pid in $nvim_pids; do
        nvim_socket=$(find /var/folders /tmp -name "nvim.${nvim_pid}.*" -type s 2>/dev/null | head -n 1)
        if [[ -n "$nvim_socket" ]]; then
            current_file=$(nvim --server "$nvim_socket" --headless --remote-expr "expand('%:p')" 2>/dev/null | cat)
            if [[ -n "$current_file" ]] && [[ -f "$current_file" ]]; then
                results+=("$current_file")
            fi
        fi
    done
done

# --- handle results ---
results=($(printf "%s\n" "${results[@]}" | sort -u))
count=${#results[@]}
current_pane=$(tmux display-message -p '#{pane_id}')

if (( count == 0 )); then
    tmux display-message "No Neovim buffers found."
elif (( count == 1 )); then
    # Insert directly into current pane (no Enter)
    tmux send-keys -t "$current_pane" "${results[0]}"
else
    # Open new pane for selection
    tmux split-window -v -p 30 "printf '%s\n' \"${results[@]}\" | fzf --reverse --prompt='Select file: ' | tmux load-buffer - && tmux send-keys -t $current_pane \"\$(tmux show-buffer)\""
fi
