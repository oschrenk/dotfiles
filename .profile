# my paths
if [ -f ~/.paths ]; then
  . ~/.paths
fi

# set defunkt/hub environment variables
# not included in dotfiles repo because of security reasons
# export GITHUB_USER=<username>
# export GITHUB_TOKEN=<token>
if [ -f ~/.github ]; then
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
shopt -s no_empty_cmd_completion # Bash will not attempt to search the PATH for possible completions when completion is attempted on an empty line.

# Enable some Bash 4 features when possible:
# `autocd`. Since 4.0-alpha. e.g. `**/qux` will enter `./foo/bar/baz/qux`
# `dirspell` Since 4.0-alpha. Bash will perform spelling corrections on directory names to match a glob.
# `globstar`.Since 4.0-alpha. Recursive globbing with `**` is enabled
for option in autocd dirspell globstar; do
  tmp="$(shopt -q "$option" 2>&1 > /dev/null | grep "invalid shell option name")"
  if [ '' == "$tmp" ]; then
    shopt -s "$option"
  fi
done

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