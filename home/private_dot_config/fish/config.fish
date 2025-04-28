set fish_greeting

# login shell:
# - given to a user upon login into their user account
# - sets up $PATH and other env variables
if status --is-login
    source ~/.config/fish/env.fish

    # 1password plugins
    source ~/.config/op/plugins.sh
end

# interactive shell:
# - connected to a keyboard.
if status --is-interactive
    # Enable direnv
    eval (direnv hook fish)

    # source aliases
    source ~/.config/fish/aliases.fish

    # enable starship
    starship init fish | source

    # enable zoxide
    zoxide init fish | source

    # atuin: disable automatic keybindings
    set -gx ATUIN_NOBIND true

    # enable atuin
    atuin init fish | source
end
