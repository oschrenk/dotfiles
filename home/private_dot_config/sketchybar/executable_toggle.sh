#!/usr/bin/env zsh

CURRENT_LINK=$(readlink -- sketchybarrc)

case "$CURRENT_LINK" in
  *lua*) task sh;;
  *sh*)  task lua;;
  *)     echo "Can't find type of file";;
esac
