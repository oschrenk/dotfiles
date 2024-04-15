function cssh
    set session_name (uuidgen | head -c 8)
    tmux new-session -s $session_name -d

    for host in $argv
        tmux split-window -t $session_name "fish -c 'ssh $host'"

        # This needs to be run after every `split-window`, otherwise eventually panes become too small
        tmux select-layout -t $session_name tiled
    end
    # Kill the first pane, which is a regular shell and not `ssh`
    tmux kill-pane -t 0

    tmux select-layout -t $session_name tiled
    tmux set-window -t $session_name synchronize-panes

    tmux attach -t $session_name
end
