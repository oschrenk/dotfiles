#!/bin/sh
sessions=$(rex ls --json | grep -c '"session_id"')
blocks=$(rex block ls -s "$REX_SESSION" --json | grep -c '"block_id"')

if [ "$sessions" = 1 ] && [ "$blocks" = 1 ]; then
  rex session rename "$REX_SESSION" ops/dotfiles
  cd "$HOME/Projects/ops/dotfiles" || true
fi

exec "$SHELL" -l
