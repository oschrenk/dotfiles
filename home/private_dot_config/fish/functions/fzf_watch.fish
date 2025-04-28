function fzf_watch --description "Watch video"
    set -l base_dir_normal "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Watch"

    set -q FZF_TMUX_HEIGHT; or set FZF_TMUX_HEIGHT 40%
    set -lx FZF_DEFAULT_OPTS "--height $FZF_TMUX_HEIGHT --reverse $FZF_DEFAULT_OPTS"

    find -L "$base_dir_normal" -type f -maxdepth 4 | cut -d / -f 8- | grep -iE 'mkv|mp4' | fzf >"$TMPDIR/fzf.result"

    # Fish hangs if the command before pipe redirects (2> /dev/null)
    [ (cat $TMPDIR/fzf.result | wc -l) -gt 0 ]
    and open "$base_dir_normal"/(cat $TMPDIR/fzf.result)
    rm -f $TMPDIR/fzf.result
end
