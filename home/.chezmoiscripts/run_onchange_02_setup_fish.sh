#!/bin/sh

if grep -Fxq "/usr/local/bin/fish" /private/etc/shells
then
  echo "fish is already configured as acceptable shell"
else
  echo "Adding fish list of acceptable shells in /private/etc/shells"
  sudo sh -c "echo /usr/local/bin/fish >> /private/etc/shells"
fi

TARGET_SHELL="/usr/local/bin/fish"
CURRENT_SHELL=$(dscl . -read ~/ UserShell | sed 's/UserShell: //')

if [ "$CURRENT_SHELL" = "$TARGET_SHELL" ]; then
  echo "fish is already the default shell"
else
  # Setup fish as default shell
  # Change the shell for the user
  sudo chsh -s $TARGET_SHELL
fi
