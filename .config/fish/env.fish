# This file is sourced on login shells only
# (responsible for setting up initial environment)

set -gx PATH /bin
append-to-path /sbin
append-to-path /usr/bin
append-to-path /usr/sbin

# put homebrew bin before system bin
prepend-to-path /usr/local/sbin
prepend-to-path /usr/local/bin

# local scripts
append-to-path ~/.scripts

# editor
set EDITOR vim

# Set locale
set -gx LC_ALL en_US.UTF-8
set -gx LANG en_US.UTF-8
