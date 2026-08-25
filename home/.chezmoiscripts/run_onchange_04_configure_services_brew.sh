#!/bin/sh

# manually select services
# for an overview do `brew services list`
for SERVICE in "tmignore-rs" "ollama" "obsidian-headless"; do
  brew services start "$SERVICE"
done
