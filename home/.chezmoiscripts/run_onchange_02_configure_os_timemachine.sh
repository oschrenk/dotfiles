#!/bin/sh

#######################################
# TIME MACHINE
#######################################

echo "Time Machine: Exclude directories from Time Machine backups"
tmutil addexclusion ~/Downloads
tmutil addexclusion ~/Movies

