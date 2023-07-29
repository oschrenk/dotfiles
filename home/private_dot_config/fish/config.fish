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

set -g theme_display_cmd_duration no
set -g theme_display_date no
set -g theme_display_git_ahead_verbose yes
set -g theme_display_git_dirty_verbose yes
set -g theme_display_git_stashed_verbose yes
set -g theme_display_git_untracked no
set -g theme_display_virtualenv no
set -g theme_nerd_fonts yes
set -g theme_newline_cursor clean

# only show k8s context when in $HOME/Projects
function react_to_pwd --on-variable PWD
  if string match -e -- "$HOME/Projects" "$PWD"
    set -g theme_display_k8s_context yes
    set -g theme_display_k8s_namespace yes
  else
    set -g theme_display_k8s_context no
    set -g theme_display_k8s_namespace no
  end
end
