function fzf_nvim --description "Open file in nvim"
  eval "$FZF_CTRL_T_COMMAND" | fzf --ansi --no-sort --reverse --preview '~/.config/nvim/plugged/fzf.vim/bin/preview.sh {} | head -200' | while read -l r; set result $result $r; end
  if [ -z $result ]
    commandline -f repaint
else
    nvim $result
  end
end
