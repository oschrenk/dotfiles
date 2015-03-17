alias ..    'cd ..'
alias ...   'cd ../..'
alias ....  'cd ../../..'
alias ..... 'cd ../../../..'
alias -     'cd -'

alias md   'mkdir -p'

alias d    'cd $HOME/Downloads'
alias p    'cd $HOME/Projects'
alias n    'cd $HOME/Documents/Notes'

alias a    'ag --smart-case'
alias c    clear
alias g    git
alias v    vim


alias shiftr "sed -Ee 's/^/    /'"
alias shiftl "sed -Ee 's/^([ ]{4}|[\t])//'"
alias map 'xargs -n1'
alias collapse "sed -e 's/  */ /g'"
alias cuts 'cut -d\ '

# Make user executable
alias cux  'chmod u+x'
