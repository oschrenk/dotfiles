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
set -x JAVA_HOME /Library/Java/JavaVirtualMachines/jdk1.8.0_201.jdk/Contents/Home
set -x SCALA_HOME /usr/local/opt/scala/
set -x SBT_OPTS "-Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled"

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

