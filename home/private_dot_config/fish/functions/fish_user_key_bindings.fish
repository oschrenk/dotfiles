# import default fzf key bindings
fzf_key_bindings

# !!! NEVER bind \cm
# Ctrl+M is the same as return
# I thought one can remap it but it will mess up fish

bind \cp fzf_projects
bind \co fzf_nvim
bind \cg fzf_commits
bind \cb fzf_branches
bind \cw fzf_watch

# fish 4.x binds ctrl+dash
#  which clashes with my tmux binding for h-split
bind --erase --preset ctrl-_
