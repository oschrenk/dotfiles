function fzf_zoxide --description "Open directory"
    zoxide query --list | fzf >"$TMPDIR/fzf.result"

    [ (cat $TMPDIR/fzf.result | wc -l) -gt 0 ]
    and cd "$(cat "$TMPDIR/fzf.result")"
    commandline -f repaint
    rm -f $TMPDIR/fzf.result
end
