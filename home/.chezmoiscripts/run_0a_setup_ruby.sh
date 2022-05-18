#!/bin/sh

if ! command -v rbenv &> /dev/null
then
    echo "rbenv could not be found"
    exit 1
fi

# Setup ruby
mkdir -p $HOME/.rbenv

# filters non-MRI versions with hyphen
# latest version
# RUBY_VERSION=$(rbenv install -l 2> /dev/null | grep -v - | tail -1)

# latest 2.x version
# RUBY_VERSION=$(rbenv install -l 2> /dev/null | grep -v - | tail -1)

# pinning specific version to make idempotent
TARGET_RUBY_VERSION="2.7.6"
CURRENT_RUBY_VERSION=$(rbenv global)

if [ "$CURRENT_RUBY_VERSION" = "$TARGET_RUBY_VERSION" ]; then
  echo "Aleady running ruby $CURRENT_RUBY_VERSION"
  rbenv rehash
else
  rbenv uninstall $CURRENT_RUBY_VERSION
  rbenv install $TARGET_RUBY_VERSION
  rbenv global $TARGET_RUBY_VERSION
  rbenv rehash
fi
