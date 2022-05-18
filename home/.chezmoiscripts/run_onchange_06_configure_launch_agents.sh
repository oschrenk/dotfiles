#!/bin/sh

BASEDIR="$( chezmoi source-path )/../assets/agents"
# launch agents
for SERVICE in "com.oschrenk.homebrew"; do
  FILE="$BASEDIR/$SERVICE.plist"
  # copy it to user's library
  echo "Copying $FILE to $HOME/Library/LaunchAgents"
  cp $FILE $HOME/Library/LaunchAgents

  # enable it
  # we rely on the filename being the name of the service
  # first cut removes ./modules/agents prefix
  # seond cut removes .plist postfix
  USER_ID=$(id -u)
  TARGET_SPECIFIER="gui/$USER_ID/$SERVICE"
  echo "Enabling $SERVICE"
  launchctl enable $TARGET_SPECIFIER
done
