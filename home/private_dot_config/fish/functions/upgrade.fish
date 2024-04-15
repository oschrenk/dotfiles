function upgrade --description "Upgrade homebrew, mas, nvim, tpm, fisher"
    # upgrade homebrew
    brew upgrade

    # upgrade macos applications
    # waiting for https://github.com/mas-cli/mas/pull/496
    mas upgrade

    # upgrade neovim plugins
    nvim --headless "+Lazy! sync" +qa

    # upgrade tmux plugins
    $XDG_CONFIG_HOME/tmux/plugins/tpm/bin/update_plugins all

    # upgrade fisher plugins
    fisher update
end
