# This file is sourced on login shells only
# (responsible for setting up initial environment)

set -gx PATH /bin
append-to-path /sbin
append-to-path /usr/bin
append-to-path /usr/sbin

# put homebrew bin before system bin
prepend-to-path /usr/local/sbin
prepend-to-path /usr/local/bin

# rbenv
prepend-to-path $HOME/.rbenv/bin
prepend-to-path $HOME/.rbenv/shims

# local scripts
append-to-path ~/.scripts

# mac applications
append-to-path /Applications/Karabiner.app/Contents/Library/bin/

# editor
set -x EDITOR vim

# Java Options
set -x MAVEN_OPTS "-Xmx512m"
set -x JAVA_HOME (/usr/libexec/java_home -v 1.8)
set -x SCALA_HOME /usr/local/opt/scala/
set -x SPARK_HOME $HOME/Frameworks/spark

# Set locale
set -gx LC_ALL en_US.UTF-8
set -gx LANG en_US.UTF-8
