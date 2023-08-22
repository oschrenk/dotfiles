function upgrade --description "Upgrade homebrew, nvim, mas"
  brew upgrade
  # waiting for https://github.com/mas-cli/mas/pull/496
  # mas upgrade
  nvim --headless "+Lazy! sync" +qa
end
