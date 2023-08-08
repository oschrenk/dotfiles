# This file is sourced on login shells only
# (responsible for setting up initial environment)

# set
# -g or --global
#        Sets a globally-scoped variable.  Global variables are available to all
#        functions running in the same shell.  They can be modified or erased.
# --export or -x
#        Causes the specified shell variable to be exported to child processes
#        (making it an "environment variable").

# put homebrew bin before system bin
fish_add_path --prepend /opt/homebrew/sbin
fish_add_path --prepend /opt/homebrew/bin

# editor
set -x EDITOR nvim

# Set locale
set -gx LC_ALL en_US.UTF-8
set -gx LANG en_US.UTF-8

# Go
set -x GOPATH $HOME/Frameworks/go
set -x GOBIN $GOPATH/bin
fish_add_path --prepend $GOPATH/bin

# Ruby
fish_add_path --prepend $HOME/.rbenv/shims

# JVM
set -x JAVA_HOME (/usr/libexec/java_home -v 11)
set -x SCALA_HOME /usr/local/opt/scala/

# Android
set -x ANDROID_HOME $HOME/Library/Android/sdk
fish_add_path --append $ANDROID_HOME/emulator
fish_add_path --append $ANDROID_HOME/tools
fish_add_path --append $ANDROID_HOME/tools/bin
fish_add_path --append $ANDROID_HOME/platform-tools

# Rust
fish_add_path --prepend $HOME/.cargo/bin

# Python
pyenv init - | source

# kubectl krew
fish_add_path --prepend $HOME/.krew/bin

# homebrew
set -x HOMEBREW_NO_ANALYTICS 1
set -x HOMEBREW_NO_ENV_HINTS

# fzf
# control how fzf is executed when doing :Files in vim
# relies on `brew install ripgrep`
# --files: List files that would be searched but do not search
# --no-ignore: Do not respect .gitignore, etc...
# --hidden: Search hidden files and folders
# --follow: Follow symlinks
# --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!{.git,node_modules,target}/*"'

# relies on `brew install fd`
export FZF_CTRL_T_COMMAND='fd --type f --type d --hidden --follow --exclude .git'

set -x SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# k8s
set -x KUBECONFIG (find $HOME/.kube/config.d -name "*.yml" -o -name '*.yaml' | sort | xargs echo | sed 's/ /:/g')

