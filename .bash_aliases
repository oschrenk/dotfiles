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

if [ "${OS}" = "linux" ] ; then
	alias open='xdg-open'
fi

if [ "${OS}" = "mac" ] ; then
	alias m='mate'
	alias vlc='/Applications/VLC.app/Contents/MacOS/VLC'
fi

# application shorthands
alias g='git'
alias o='open'
alias j='z'
alias gsh='git sh'

# other aliases
alias ttop='top -ocpu -R -F -s 2 -n30'
alias psef='ps -ef | grep -i $1'

if [ "${OS}" = "linux" ] ; then
	alias open='xdg-open'
fi
