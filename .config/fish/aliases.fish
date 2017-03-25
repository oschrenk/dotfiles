alias ..    'cd ..'
alias ...   'cd ../..'
alias ....  'cd ../../..'
alias ..... 'cd ../../../..'
abbr -a -- - 'cd -'

alias md   'mkdir -p'

alias d    'cd $HOME/Downloads'
alias h    'cd $HOME'
alias p    'cd $HOME/Projects'
alias n    'cd $HOME/Documents/Notes'
alias l    'cd $HOME/Documents/Log'

# Applications
alias a    'ag'
alias be   'bundle exec'
alias c    clear
alias e    nvim
alias g    git
alias s    spotifish

# tmux sessions
alias tk   'tmux kill-session -t'
alias tl   'tmuxp load -2 -y'

alias shiftr "sed -Ee 's/^/    /'"
alias shiftl "sed -Ee 's/^([ ]{4}|[\t])//'"
alias map 'xargs -n1'
alias collapse "sed -e 's/  */ /g'"
alias cuts 'cut -d\ '

alias cux  'chmod u+x'
alias vim  'nvim'
