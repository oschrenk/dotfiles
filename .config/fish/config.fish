# source aliases
if test -r ~/.config/fish/aliases.fish
  source ~/.config/fish/aliases.fish
end

if status --is-login
    source ~/.config/fish/env.fish
end

# local configurations
if test -r ~/.config/fish/local.fish
  source ~/.config/fish/local.fish
end

# Enable direnv
eval (direnv hook fish)

set -g theme_newline_cursor yes

