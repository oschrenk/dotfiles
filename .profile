# my paths
if [ -f ~/.paths ]; then
  . ~/.paths
fi

# defunkt/hub github environment variables
if [ -f ~/.paths ]; then
  . ~/.github
fi

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
shopt -s dirspell # Since 4.0-alpha. Bash will perform spelling corrections on directory names to match a glob.
shopt -s globstar # Since 4.0-alpha. Recursive globbing with `**` is enabled
shopt -s autocd # Since 4.0-alpha. If set, a command name that is the name of a directory is executed as if it were the argument to the cd command.

# set os, dist, rev, kernel, mach environment variables
if [ -f $SCRIPTS/setos ]; then
    . $SCRIPTS/setos
fi

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

# z s the new j, https://github.com/rupa/z
if [ -f `brew --prefix`/etc/profile.d/z.sh ]; then
  . `brew --prefix`/etc/profile.d/z.sh
fi

# include pickjdk script
if [ -f $SCRIPTS/pickjdk ]; then
    . $SCRIPTS/pickjdk
fi

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi