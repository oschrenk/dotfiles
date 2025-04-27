# import default fzf key bindings
fzf_key_bindings

bind \cp fzf_projects
bind \co fzf_nvim
bind \cg fzf_commits
bind \cb fzf_branches
bind \ct fzf_datepicker

# fish 4.x binds ctrl+dash
#  which clashes with my tmux binding for h-split
bind --erase --preset ctrl-_
