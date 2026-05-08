function fzf_commits --description "Browse git commits using fzf"
    git log --oneline --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" \
        | fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
        --bind "ctrl-m:execute: echo '{}' | grep -o '[a-f0-9]\{7\}' | head -1 | xargs -I SHA fish -c 'git show --color=always SHA | less -R'"
end
