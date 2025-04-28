function fzf_zoxide --description "Open directory"
    zoxide query --list | fzf
end
