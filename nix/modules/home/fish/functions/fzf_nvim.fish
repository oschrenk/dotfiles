function fzf_nvim --description "Open file in nvim"
    eval "$FZF_CTRL_T_COMMAND" | fzf --ansi --no-sort --reverse --preview '~/.config/nvim/scripts/preview.sh {} | head -50' | while read -l r
        set result $result $r
    end
    if [ -z $result ]
        commandline -f repaint
    else
        nvim $result
    end
end
