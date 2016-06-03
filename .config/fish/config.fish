. ~/.config/fish/aliases.fish

if status --is-login
    . ~/.config/fish/env.fish
end

# local configurations
if test -r ~/.config/fish/local.fish
  source ~/.config/fish/local.fish
end

# Disable default theme
function fish_mode_prompt
end function

# vi mode, start in insert mode
fish_vi_key_bindings
set -g __fish_vi_mode 1

# enable vi_mode in bob the fish theme
set -g theme_display_vi yes

# Color scheme
source $HOME/.config/fish/gruvbox_256palette_osx.fish

