. ~/.config/fish/aliases.fish

if status --is-login
    . ~/.config/fish/env.fish
end

# local configurations
if test -r ~/.config/fish/local.fish
  source ~/.config/fish/local.fish
end

# vi mode, start in insert mode
set fish_bind_mode insert

# Color scheme
source $HOME/.config/fish/gruvbox_256palette_osx.fish

set -g theme_display_vi yes
