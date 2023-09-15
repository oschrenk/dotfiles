# Navigation
alias ..    'cd ..'
alias ...   'cd ../..'
alias ....  'cd ../../..'
alias ..... 'cd ../../../..'
abbr -a -- - 'cd -'

alias d 'cd $HOME/Downloads'
alias p 'cd $HOME/Projects'

# Applications
alias a 'ag'
alias b 'brew'
alias c 'chezmoi'
alias g 'git'
alias k 'kubectl'
alias t 'task'

alias ios 'open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app'

# chezmoi
alias che 'cd (chezmoi source-path)/..'

# Make user executable
alias cux 'chmod u+x'

# Sound
# requires `brew install sox`
alias noise 'play -q -c 2 --null synth brownnoise band -n 2500 4000 tremolo 20 .1 reverb 50'

# Fun
alias meow 'cat'
