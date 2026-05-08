function fzf_branches --description "Browse git branches using fzf"

    set -q FZF_TMUX_HEIGHT; or set FZF_TMUX_HEIGHT 40%
    set -lx FZF_DEFAULT_OPTS "--height $FZF_TMUX_HEIGHT --reverse $FZF_DEFAULT_OPTS"

    set --local FZF_PROJECT_COMMAND "git branch --format '%(refname:short)' --no-color --sort=-committerdate"

    # Fish hangs if the command before pipe redirects (2> /dev/null)
    eval "$FZF_PROJECT_COMMAND | "(__fzfcmd)" > $TMPDIR/fzf.result"
    [ (cat $TMPDIR/fzf.result | wc -l) -gt 0 ]
    and git switch (cat $TMPDIR/fzf.result)
    commandline -f repaint
    rm -f $TMPDIR/fzf.result
end
