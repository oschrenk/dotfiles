function update --description "update system"
  brew update --all; and brew outdated; and brew upgrade
  vim +PlugUpgrade +PlugClean! +PlugUpdate
end
