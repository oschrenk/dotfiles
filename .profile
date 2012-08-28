export EDITOR=vi
export SVN_EDITOR=vi

# bigger history
export HISTSIZE=10000
export HISTFILESIZE=${HISTSIZE}

# any lines matching the previous history entry will not be saved
export HISTCONTROL=ignoreboth

# patterns of commands that will be ignored and NOT added to history
# export HISTIGNORE="ls:ls -lA"

# set os, dist, rev, kernel, mach environment variables
if [ -f $SCRIPTS/setos ]; then
    . $SCRIPTS/setos
fi

# include sshagent script
if [ -f $SCRIPTS/sshagent ]; then
    . $SCRIPTS/sshagent
fi

# include pickjdk script
if [ -f $SCRIPTS/pickjdk ]; then
    . $SCRIPTS/pickjdk
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

# rmv ruby environment manager
if [ -f ~/.rvm/scripts/rvm ]; then
  source ~/.rvm/scripts/rvm
fi


# z s the new j, https://github.com/rupa/z
if [ -f `brew --prefix`/etc/profile.d/z.sh ]; then
  . `brew --prefix`/etc/profile.d/z.sh
fi

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi