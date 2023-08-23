function upgrade --description "Upgrade homebrew, nvim, mas"
  brew upgrade
  # waiting for https://github.com/mas-cli/mas/pull/496
  # mas upgrade
  nvim --headless "+Lazy! sync" +qa
  $XDG_CONFIG_HOME/tmux/plugins/tpm/bin/update_plugins all
end
