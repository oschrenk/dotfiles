alias ..    'cd ..'
alias ...   'cd ../..'
alias ....  'cd ../../..'
alias ..... 'cd ../../../..'
abbr -a -- - 'cd -'

alias md   'mkdir -p'

alias d    'cd $HOME/Downloads'
alias h    'cd $HOME'
alias p    'cd $HOME/Projects'
alias r    'cd $HOME/Repos'
alias n    'cd $HOME/Documents/Notes'

# Applications
alias a    'ag'
alias be   'bundle exec'
alias c    clear
alias e    nvim
alias j    'nvim -c "Goyo"'
alias g    git
alias s    spotifish

alias chrome 'open /Applications/Google\ Chrome.app/ --args --allow-file-access-from-files --remote-debugging-port=9222'
alias ios 'open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app'

# tmux sessions
alias tk   'tmux kill-session -t'
alias tl   'tmuxp load -2 -y'

# Make user executable
alias cux  'chmod u+x'
alias vim  'nvim'
