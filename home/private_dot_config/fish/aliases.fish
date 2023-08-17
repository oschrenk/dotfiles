# Navigation
alias ..    'cd ..'
alias ...   'cd ../..'
alias ....  'cd ../../..'
alias ..... 'cd ../../../..'
abbr -a -- - 'cd -'

alias d    'cd $HOME/Downloads'
alias p    'cd $HOME/Projects'

# Applications
alias c   'cd (chezmoi source-path)'
alias cux 'chmod u+x'
alias g   git
alias ios 'open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app'
alias k   kubectl
alias t   terraform

# Sound
# requires `brew install sox`
alias noise 'play -q -c 2 --null synth brownnoise band -n 2500 4000 tremolo 20 .1 reverb 50'
alias tng 'play -c2 -n synth whitenoise band -n 100 24 band -n 300 100 gain +5'

