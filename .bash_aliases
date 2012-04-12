# ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lsd='ls -l | grep "^d"'

# cd aliases
alias --='cd -'
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
	alias update='brew update'
	alias upgrade='brew upgrade && npm -g update && mateup'
fi

# application shorthands
alias j='z'
alias o='open'
alias r='rake'
alias g='git sh'

# other aliases
alias ttop='top -ocpu -R -F -s 2 -n30'
alias psef='ps -ef | grep -i $1'