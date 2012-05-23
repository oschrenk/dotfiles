# ls aliases
alias ll='ls -GalF'
alias la='ls -GA'
alias l='ls -GCF'
alias lsd='ls -Gl | grep "^d"'

# cd aliases
alias ..='cd ..'
alias ...='cd ../..'

if [ "${OS}" = "linux" ] ; then
	alias open='xdg-open'
fi

if [ "${OS}" = "mac" ] ; then
	alias loc='location' 
	alias s='subl'
	alias ss='subl'
	alias sl='subl'
	alias slime='subl'
fi

# application shorthands
alias o='open'
alias oo='open .'
alias g='git sh'

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en1"
alias ips="ifconfig -a | grep -o 'inet6\? \(\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)\|[a-fA-F0-9:]\+\)' | sed -e 's/inet6* //'"

# process managment
alias ttop='top -ocpu -R -F -s 2 -n30'
alias psef='ps -ef | grep -i $1'