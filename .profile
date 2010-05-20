export SCRIPTS=~/Development/scripts

export PATH=/opt/local/bin:$PATH
export PATH=/opt/local/sbin:$PATH
export PATH=$SCRIPTS:$PATH

export MANPATH=/opt/local/share/man:$MANPATH

# LEJOS
export NXJ_HOME=~/Development/sdk/lejos_nxj
export PATH=~/Development/sdk/lejos_nxj/bin:$PATH
# optional for use with Eclipse plugin
# export DYLD_LIBRARY_PATH=$NXJ_HOME/bin;

export EDITOR=vi
export SVN_EDITOR=vi

# bigger history	
export HISTSIZE=10000
export HISTFILESIZE=${HISTSIZE}

# any lines matching the previous history entry will not be saved
export HISTCONTROL=ignoreboth

# patterns of commands that will be ignored and NOT added to history
# export HISTIGNORE="ls:ls -lA"

shopt -s histappend #append to the same history file when using multiple terminals
shopt -s cdspell #minor errors in the spelling of a directory component in a cd command will be corrected
shopt -s nocaseglob #when typing part of a filename and press Tab to autocomplete, Bash does a case-insensitive search.
shopt -s cmdhist # Save multi-line commands in history as single line

# useful alias
alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias ttop='top -ocpu -R -F -s 2 -n30'

alias grace='sudo /opt/local/apache2/bin/apachectl graceful'

md() { mkdir -p "$1" && cd "$1"; }

# Setup SSH-agent found at http://www.cygwin.com/ml/cygwin/2001-06/msg00537.html
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
     echo "Initialising new SSH agent..."
     /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
     echo succeeded
     chmod 600 "${SSH_ENV}"
     . "${SSH_ENV}" > /dev/null
     /usr/bin/ssh-add;
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
     . "${SSH_ENV}" > /dev/null
     #ps ${SSH_AGENT_PID} doesn't work under cywgin
     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
         start_agent;
     }
else
     start_agent;
fi 

# include pickjdk script
if [ -f $SCRIPTS/pickjdk ]; then
    . $SCRIPTS/pickjdk
fi