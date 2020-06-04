# This file is sourced on login shells only
# (responsible for setting up initial environment)

# put homebrew bin before system bin
prepend-to-path /usr/local/sbin
prepend-to-path /usr/local/bin

# LOG and JOURNAL
set -x LOG_DIR ~/Documents/Log
set -x JOURNAL_DIR ~/Documents/Journal

# editor
set -x EDITOR nvim

# Set locale
set -gx LC_ALL en_US.UTF-8
set -gx LANG en_US.UTF-8

# Go
set -x GOPATH $HOME/Frameworks/go
set -x GOBIN $GOPATH/bin
prepend-to-path $GOPATH/bin

# Ruby
prepend-to-path $HOME/.rbenv/shims

# JVM
set -x JAVA_HOME (/usr/libexec/java_home -v 11)
set -x SCALA_HOME /usr/local/opt/scala/
set -x SBT_OPTS "-Xms1024M -Xmx2048M -Xss4M -XX:+CMSClassUnloadingEnabled"

# Android
set -x ANDROID_HOME $HOME/Library/Android/sdk
append-to-path $ANDROID_HOME/emulator
append-to-path $ANDROID_HOME/tools
append-to-path $ANDROID_HOME/tools/bin
append-to-path $ANDROID_HOME/platform-tools

# Python
append-to-path $HOME/Library/Python/3.7/bin

# Rust
prepend-to-path $HOME/.cargo/bin

# Latex
append-to-path /Library/TeX/texbin

# homebrew
set -x HOMEBREW_NO_ANALYTICS 1

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

# yubikey
# relies on installation of https://github.com/FiloSottile/yubikey-agent
export SSH_AUTH_SOCK="/usr/local/var/run/yubikey-agent.sock"
