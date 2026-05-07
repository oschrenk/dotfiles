####################
# KEY BINDINGS
####################
#
# !!! NEVER bind \cm
# Ctrl+M is the same as return
# I thought one can remap it but it will mess up fish
# 
# To list all bindings
#   bind -a
#
# To list preset bindings
#   bind -a | grep preset | sort
#   bind -a | grep preset | grep ctrl | sort

# load fzf shell integration (defines fzf_key_bindings + __fzf_parse_commandline,
# installs Ctrl-T / Ctrl-R / Alt-C). Sourced here because fish is chezmoi-managed,
# so HM's programs.fzf.enableFishIntegration is a no-op.
fzf --fish | source

# fzf related user functions
bind \cp sessionizer_cd
bind \co fzf_nvim
bind \cg fzf_commits
bind \cb fzf_branches

# atuin
bind \cR _atuin_search

# fish 4.x binds ctrl+dash
#  which clashes with my tmux binding for h-split
bind --erase --preset ctrl-_
