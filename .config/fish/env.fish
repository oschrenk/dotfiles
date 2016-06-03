# This file is sourced on login shells only
# (responsible for setting up initial environment)

# put homebrew bin before system bin
prepend-to-path /usr/local/sbin
prepend-to-path /usr/local/bin

# mac applications
append-to-path /Applications/Karabiner.app/Contents/Library/bin/

# editor
set -x EDITOR vim

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

# Latex
append-to-path /Library/TeX/texbin

