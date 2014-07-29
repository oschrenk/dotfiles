. ~/.config/fish/aliases.fish

if status --is-login
    . ~/.config/fish/env.fish
end


# local configurations
if test -r ~/.config/fish/local.fish
  source ~/.config/fish/local.fish
end
