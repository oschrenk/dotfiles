# Navigation
alias ..    'cd ..'
alias ...   'cd ../..'
alias ....  'cd ../../..'
alias ..... 'cd ../../../..'
abbr -a -- - 'cd -'

alias d    'cd $HOME/Downloads'
alias p    'cd $HOME/Projects'
alias n    'cd $HOME/Projects/personal/notes'

# Applications
alias a    'ag'
alias c    clear
alias ci   'open https://circleci.com/dashboard'
alias g    git
alias k    kubectl
alias j    journal
alias t    terraform


alias ios 'open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app'

# tmux sessions
alias tk   'tmux kill-session -t'
alias tl   'tmuxp load -2 -y'

# Make user executable
alias cux  'chmod u+x'

# Sound
# requires `brew install sox`
alias noise 'play -q -c 2 --null synth brownnoise band -n 2500 4000 tremolo 20 .1 reverb 50'
alias tng 'play -c2 -n synth whitenoise band -n 100 24 band -n 300 100 gain +20'

# Fun
alias meow 'cat'
