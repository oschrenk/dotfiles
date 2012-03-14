# ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lsd='ls -l | grep "^d"'

# cd aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# application shorthands
alias g='git'
alias o='open'
alias m='mate'
alias j='z'

# other aliases
alias ttop='top -ocpu -R -F -s 2 -n30'
alias psef='ps -ef | grep -i $1'

if [ "${OS}" = "linux" ] ; then
	alias open='xdg-open'
fi