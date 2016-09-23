# This file is sourced on login shells only
# (responsible for setting up initial environment)

# put homebrew bin before system bin
prepend-to-path /usr/local/sbin
prepend-to-path /usr/local/bin

#
set -x LOG_DIR ~/Documents/Log

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

# Rust
prepend-to-path $HOME/.cargo/bin

# JVM
set -x MAVEN_OPTS "-Xmx512m"
set -x JAVA_HOME (/usr/libexec/java_home -v 1.8)
set -x SCALA_HOME /usr/local/opt/scala/
set -x SPARK_HOME $HOME/Frameworks/spark
set -x SBT_OPTS "-Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled"

# Latex
append-to-path /Library/TeX/texbin

# Fix tmux on macOS sierra
set -x EVENT_NOKQUEUE 1
