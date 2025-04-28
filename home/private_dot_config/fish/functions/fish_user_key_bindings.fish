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

# import default fzf key bindings
fzf_key_bindings

# fzf related user functions
bind \cp fzf_projects
bind \co fzf_nvim
bind \cg fzf_commits
bind \cb fzf_branches
bind \cw fzf_watch
bind \cz fzf_zoxide

# fish 4.x binds ctrl+dash
#  which clashes with my tmux binding for h-split
bind --erase --preset ctrl-_
