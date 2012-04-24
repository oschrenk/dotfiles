# ls aliases
alias ll='ls -GalF'
alias la='ls -GA'
alias l='ls -GCF'
alias lsd='ls -Gl | grep "^d"'

# cd aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

if [ "${OS}" = "linux" ] ; then
	alias open='xdg-open'
fi

if [ "${OS}" = "mac" ] ; then
	alias m='mate'
	alias mm='mate .'
fi

# application shorthands
alias o='open'
alias oo='open .'
alias g='git sh'

# other aliases
alias ttop='top -ocpu -R -F -s 2 -n30'
alias psef='ps -ef | grep -i $1'