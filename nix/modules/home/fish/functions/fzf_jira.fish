function fzf_jira -d "List tickets"
    set -l commandline (__fzf_parse_commandline)
    set -l fzf_query $commandline[2]

    set -l FZF_JIRA_COMMAND "command jira sprint"

    test -n "$FZF_TMUX_HEIGHT"; or set FZF_TMUX_HEIGHT 40%
    begin
        set -lx FZF_DEFAULT_OPTS "--height $FZF_TMUX_HEIGHT --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS"
        eval "$FZF_JIRA_COMMAND | "(__fzfcmd)' -m --query "'$fzf_query'"' | while read -l r
            set result $result $r
        end
    end
    if [ -z "$result" ]
        commandline -f repaint
        return
    else
        # Remove last token from commandline.
        commandline -t ""
    end
    echo $result
    for i in $result
        commandline -it -- $prefix
        commandline -it -- (string split -f1 ':' $i)
    end
    commandline -f repaint
end
