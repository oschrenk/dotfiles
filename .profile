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