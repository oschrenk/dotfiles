if status --is-login
  source ~/.config/fish/env.fish

  #  set -xg OPENAI_API_KEY (op read "op://Personal/auth0.openai.com/d3szyypowp4f2idhk2kebufl7e")
end

if status --is-interactive

  # Enable direnv
  eval (direnv hook fish)

  # source aliases
  if test -r ~/.config/fish/aliases.fish
    source ~/.config/fish/aliases.fish
  end


  set -g theme_display_cmd_duration no
  set -g theme_display_date no
  set -g theme_display_git_ahead_verbose yes
  set -g theme_display_git_dirty_verbose yes
  set -g theme_display_git_stashed_verbose yes
  set -g theme_display_git_untracked no
  set -g theme_display_virtualenv no
  set -g theme_nerd_fonts yes
  set -g theme_newline_cursor clean
  set -g theme_display_k8s_namespace no

  # only show k8s context when in $HOME/Projects
  function react_to_pwd --on-variable PWD
    if string match -e -- "$HOME/Projects" "$PWD"
      set -g theme_display_k8s_context   yes
    else
      set -g theme_display_k8s_context   no
    end
  end
end
