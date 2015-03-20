. ~/.config/fish/aliases.fish

if status --is-login
    . ~/.config/fish/env.fish
end

# local configurations
if test -r ~/.config/fish/local.fish
  source ~/.config/fish/local.fish
end

# vi mode, start in insert mode
set -g fish_key_bindings fish_vi_key_bindings
set fish_bind_mode insert
