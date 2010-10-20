export SCRIPTS=~/Development/scripts
export SDKS=~/Development/sdks

export PATH=/usr/local/bin:/usr/local/sbin:$SCRIPTS:$PATH

# WD http://github.com/karlin/working-directory/
export WDHOME=$HOME/.wd
source $WDHOME/wdaliases.sh

# LEJOS
export NXJ_HOME=$SDKS/lejos_nxj
export PATH=$SDKS/lejos_nxj/bin:$PATH

# PLAY
export PLAY_HOME=$SDKS/play
export PATH=$PLAY_HOME:$PATH

# GAE
export GAE_HOME=$SDKS/gae
export PATH=$GAE_HOME/bin:$PATH

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

# include sshagent script
if [ -f $SCRIPTS/sshagent ]; then
    . $SCRIPTS/sshagent
fi

# bash completion
if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi

# bash completion scripts
if [ -f ~/.bash_completion.d/git ]; then
  . ~/.bash_completion.d/git
fi
if [ -f ~/.bash_completion.d/git-flow-completion ]; then
  . ~/.bash_completion.d/git-flow-completion
fi
if [ -f ~/.bash_completion.d/m2 ]; then
  . ~/.bash_completion.d/m2
fi

# include pickjdk script
if [ -f $SCRIPTS/pickjdk ]; then
    . $SCRIPTS/pickjdk
fi

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi