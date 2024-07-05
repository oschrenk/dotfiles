#!/bin/sh

# manually select services
# for an overview do `brew services list`
for SERVICE in "sketchybar" "mission"; do
  brew services start "$SERVICE"
done
