#!/bin/sh

BASEDIR="$(chezmoi source-path)/../assets/agents"

# Ensure log directory exists
mkdir -p "$HOME/.local/state/comodoro"

for SERVICE in "com.comodoro.server"; do
  FILE="$BASEDIR/$SERVICE.plist"

  echo "Copying $FILE to $HOME/Library/LaunchAgents"
  cp "$FILE" "$HOME/Library/LaunchAgents"

  USER_ID=$(id -u)
  TARGET_SPECIFIER="gui/$USER_ID/$SERVICE"

  echo "Enabling $SERVICE"
  launchctl enable "$TARGET_SPECIFIER"

  # Bootstrap (load) the service
  launchctl bootstrap "gui/$USER_ID" "$HOME/Library/LaunchAgents/$SERVICE.plist" 2>/dev/null || \
    launchctl kickstart -k "$TARGET_SPECIFIER" 2>/dev/null
done
