function fzf_watch --description "Watch video"
    set -l base_dir_normal "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Watch"

    find -L "$base_dir_normal" -type f -maxdepth 4 | cut -d / -f 8- | grep -iE 'mkv|mp4' | fzf >"$TMPDIR/fzf.result"

    [ (cat $TMPDIR/fzf.result | wc -l) -gt 0 ]
    and open "$base_dir_normal"/(cat $TMPDIR/fzf.result)
    rm -f $TMPDIR/fzf.result
end
