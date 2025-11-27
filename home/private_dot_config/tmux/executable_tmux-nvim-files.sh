#!/usr/bin/env bash
set -euo pipefail

# helper: compute relative path portably
relpath() {
    local target="$1"
    local base="$2"

    # try grealpath (GNU realpath via Homebrew on macOS)
    if command -v grealpath >/dev/null 2>&1; then
        grealpath --relative-to="$base" "$target"
        return
    fi

    # try GNU realpath (Linux)
    if command -v realpath >/dev/null 2>&1 && realpath --relative-to="$base" "$target" 2>/dev/null; then
        return
    fi

    # GNU realpath not available
    echo "Error: GNU realpath is not available. Please look into 'brew info coreutils'" >&2
    echo "$target"
}

# Get the current session and window
current_session=$(tmux display-message -p '#S')
current_window=$(tmux display-message -p '#I')

# Get list of all pane IDs in the current window
pane_ids=$(tmux list-panes -t "${current_session}:${current_window}" -F '#{pane_id}')

results=()

# Loop through each pane and check for neovim instances
for pane_id in $pane_ids; do
    # Get the PID of the process in this pane
    pane_pid=$(tmux display-message -p -t "$pane_id" '#{pane_pid}' 2>/dev/null || true)
    [[ -z "$pane_pid" ]] && continue

    # Find (direct) children of the pane process; pgrep -P may return empty
    all_descendants=$(pgrep -P "$pane_pid" 2>/dev/null || true)
    nvim_pids=""

    # Check the pane itself
    pane_command=$(ps -p "$pane_pid" -o comm= 2>/dev/null || true)
    if [[ "$pane_command" == "nvim" ]]; then
        nvim_pids="$pane_pid"
    fi

    # Check all descendants (non-recursive pgrep -P only); include whatever we get
    for desc_pid in $all_descendants; do
        desc_command=$(ps -p "$desc_pid" -o comm= 2>/dev/null || true)
        if [[ "$desc_command" == "nvim" ]]; then
            nvim_pids="$nvim_pids $desc_pid"
            nvim_children=$(pgrep -P "$desc_pid" 2>/dev/null || true)
            nvim_pids="$nvim_pids $nvim_children"
        fi
    done

    # For each nvim process, try to find its socket and query current buffer
    for nvim_pid in $nvim_pids; do
        # query the nvim process directly for its socket
        nvim_socket=$(lsof -p "$nvim_pid" -a -U 2>/dev/null | awk '/nvim\.[0-9]+\.0$/ {print $NF}')

        if [[ -n "$nvim_socket" ]]; then
            current_file=$(nvim --server "$nvim_socket" --headless --remote-expr "expand('%:p')" 2>/dev/null || true)
            current_file="${current_file//$'\r'/}"  # strip CR if any
            if [[ -n "$current_file" ]] && [[ -f "$current_file" ]]; then
                results+=("$current_file")
            fi
        fi
    done
done

# dedupe & sort
IFS=$'\n' read -r -d '' -a results < <(printf "%s\n" "${results[@]}" | sort -u && printf '\0')

count=${#results[@]}
current_pane=$(tmux display-message -p '#{pane_id}')
pane_cwd=$(tmux display-message -p -t "$current_pane" '#{pane_current_path}')

if (( count == 0 )); then
    tmux display-message "No Neovim buffers found."
elif (( count == 1 )); then
    # Compute relative path and insert (no Enter)
    rel_path=$(relpath "${results[0]}" "$pane_cwd")
    tmux send-keys -t "$current_pane" "$rel_path"
else
    # write relative paths to a temp file, one per line
    tmpfile=$(mktemp)
    trap 'rm -f "$tmpfile"' EXIT

    for f in "${results[@]}"; do
        printf '%s\n' "$(relpath "$f" "$pane_cwd")" >> "$tmpfile"
    done

    # open split, run fzf there, load selection into tmux buffer and send to original pane (no Enter)
    # The commands inside the quotes run in the new pane's shell.
    tmux split-window -v -p 30 \
        "selected=\$(cat '$tmpfile' | fzf --reverse --prompt='Select file: ' --no-multi --read0 2>/dev/null || cat '$tmpfile' | fzf --reverse --prompt='Select file: '); \
         if [[ -n \"\$selected\" ]]; then \
             tmux load-buffer -- \"\$selected\"; \
             tmux send-keys -t '$current_pane' \"\$(tmux show-buffer)\"; \
         fi; \
         rm -f '$tmpfile'"

    # note: no Enter is sent; the selected text is inserted exactly at cursor
fi
