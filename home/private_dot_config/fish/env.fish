# This file is sourced on login shells only
# (responsible for setting up initial environment)

# set
# -g or --global
#        Sets a globally-scoped variable.  Global variables are available to all
#        functions running in the same shell.  They can be modified or erased.
# --export or -x
#        Causes the specified shell variable to be exported to child processes
#        (making it an "environment variable").

#############################
# WELL KNOWN
#############################

# editor
set -x EDITOR nvim

# Set locale
set -gx LC_ALL en_US.UTF-8
set -gx LANG en_US.UTF-8

#############################
# XDG
#############################
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share

# force some apps to respect XDG
set -gx INPUTRC "$XDG_CONFIG_HOME"/readline/inputrc
set -gx WGETRC "$XDG_CONFIG_HOME"/wgetrc
set -gx RIPGREP_CONFIG_PATH $XDG_CONFIG_HOME/ripgrep/ripgreprc

#############################
# PATH
#############################
# put homebrew bin before system bin
fish_add_path --prepend /opt/homebrew/sbin
fish_add_path --prepend /opt/homebrew/bin

# put local bin before
fish_add_path --prepend $HOME/.local/bin

# Go
set -x GOPATH $HOME/Frameworks/go
set -x GOBIN $GOPATH/bin
fish_add_path --prepend $GOPATH/bin

# Ruby
fish_add_path --prepend $HOME/.rbenv/shims

# JVM
set -x JAVA_HOME (/usr/libexec/java_home -v 17)
set -x SCALA_HOME /usr/local/opt/scala/

# Android
set -x ANDROID_HOME $HOME/Library/Android/sdk
fish_add_path --append $ANDROID_HOME/emulator
fish_add_path --append $ANDROID_HOME/tools
fish_add_path --append $ANDROID_HOME/tools/bin
fish_add_path --append $ANDROID_HOME/platform-tools

# Rust
set -gx CARGO_HOME $XDG_DATA_HOME/cargo
fish_add_path --prepend $CARGO_HOME/bin

# Python
fish_add_path --prepend /opt/homebrew/opt/python@3.12/libexec/bin

# kubectl krew
fish_add_path --prepend $HOME/.krew/bin

# swift
fish_add_path /opt/homebrew/opt/swift/bin

#############################
# homebrew
#############################
# disable analytics
set -gx HOMEBREW_NO_ANALYTICS 1
# don't print hints about env variables
set -gx HOMEBREW_NO_ENV_HINTS 1
# don't show added formulae/casks after update
set -gx HOMEBREW_NO_UPDATE_REPORT_NEW 1

#############################
# fzf
#############################
# control colors/styling
set -gx FZF_DEFAULT_OPTS '--color=bw,prompt:11,fg:,bg+:,fg+: --height 40% --reverse --prompt="󰍉 " --pointer="󰘍" --border=none --no-separator --no-scrollbar --info=hidden'

# control how fzf is executed when doing :Files in vim
# relies on `brew install ripgrep`
# --files: List files that would be searched but do not search
# --no-ignore: Do not respect .gitignore, etc...
# --hidden: Search hidden files and folders
# --follow: Follow symlinks
# --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
set -gx FZF_DEFAULT_COMMAND 'rg --files --no-ignore --hidden --follow --glob "!{.git,node_modules,target}/*"'

# relies on `brew install fd`
set -gx FZF_CTRL_T_COMMAND 'fd --type f --type d --hidden --follow --exclude .git'

#############################
# ssh
#############################
# use 1password for ssh
set -x SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

#############################
# k8s
#############################
# automatically offer all $HOME/.kube/config.d/*.yml as K8s configs
set -x KUBECONFIG (find $HOME/.kube/config.d -name "*.yml" -o -name '*.yaml' | sort | xargs echo | sed 's/ /:/g')

#############################
# Claude
#############################
set -x ANTHROPIC_API_KEY (op read "op://Personal/klbcel2ndipncvrw5kx6sohzru/API Key - Avante")
