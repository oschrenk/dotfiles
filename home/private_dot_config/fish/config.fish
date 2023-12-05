set fish_greeting

if status --is-login
    source ~/.config/fish/env.fish
end

if status --is-interactive
    # Enable direnv
    eval (direnv hook fish)

    # source aliases
    source ~/.config/fish/aliases.fish

  # enable starship
  starship init fish | source
end
