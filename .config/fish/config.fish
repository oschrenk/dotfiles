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

# Disable default theme
function fish_mode_prompt
end function

# vi mode, start in insert mode
set -g __fish_vi_mode 1

# enable vi_mode in bob the fish theme
set -g theme_display_vi yes

# Enable direnv
eval (direnv hook fish)


#               light  medium dark
#               ------ ------ ------
set -l red      cc9999 ce000f 660000
set -l green    c2f200 9bbf05 0c4801
set -l blue     48b4fb 005faf 255e87
set -l orange   f6b117 unused 3a2a03
set -l brown    bf5e00 803f00 4d2600
set -l grey     cccccc 999999 333333
set -l white    ffffff
set -l black    000000
set -l ruby_red af0000

set __color_initial_segment_exit     $white $red[2] --bold
set __color_initial_segment_su       $white $green[2] --bold
set __color_initial_segment_jobs     $white $blue[3] --bold

set __color_path                     $grey[3] $grey[2]
set __color_path_basename            $grey[3] $white --bold
set __color_path_nowrite             $red[3] $red[1]
set __color_path_nowrite_basename    $red[3] $red[1] --bold

set __color_repo                     $green[1] $green[3]
set __color_repo_work_tree           $green[1] $white --bold
set __color_repo_dirty               $red[2] $white
set __color_repo_staged              $orange[1] $orange[3]

set __color_vi_mode_default          $blue[2] $blue[3] --bold
set __color_vi_mode_insert           $green[2] $grey[3] --bold
set __color_vi_mode_visual           $orange[1] $orange[3] --bold

# set __color_vi_mode_default          $grey[2] $grey[3] --bold
# set __color_vi_mode_insert           $green[2] $grey[3] --bold
# set __color_vi_mode_visual           $orange[1] $orange[3] --bold

set __color_vagrant                  $blue[1] $white --bold
set __color_username                 $grey[1] $blue[3]
set __color_rvm                      $ruby_red $grey[1] --bold
set __color_virtualfish              $blue[2] $grey[1] --bold

set -g theme_color_scheme user

