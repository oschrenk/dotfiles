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

# JVM
set -x JAVA_HOME (/usr/libexec/java_home -v 1.8)
set -x SCALA_HOME /usr/local/opt/scala/
set -x SBT_OPTS "-Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled"

# Latex
append-to-path /Library/TeX/texbin

# homebrew
set -x HOMEBREW_NO_ANALYTICS 1

# Applications

append-to-path $HOME/Projects/language/scala/delight
append-to-path $HOME/Projects/platzhaltr/datr.scala

