" ---------------------------
" fzf
" ---------------------------
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)


" ============================
" keyboard mappings
" ============================

" need to source manually
source ~/.config/nvim/plugged/vim-shortcut/plugin/shortcut.vim

Shortcut fzf | Search text
  \ nnoremap <silent> <Space>/ :execute 'Rg ' . input('Rg/')<CR>
Shortcut fzf | Search Git files
  \ noremap <Space>o :GFiles<CR>
Shortcut fzf | Search files
  \ noremap <Space>O :Files<CR>
Shortcut fzf | Search Tags
  \ noremap <Space>T :Tags<CR>
Shortcut fzf | Search Old files and buffers
  \ noremap <Space>H :History<CR>
Shortcut fzf | Search Marks
  \ noremap <Space>m :Marks<CR>
Shortcut fzf | Search Commits for current buffer
  \ noremap <Space>c :BCommits<CR>
Shortcut fzf | Search Commits
  \ noremap <Space>C :Commits<CR>
Shortcut fzf | Search Lines in current buffer
  \ noremap <Space>B :BLines<CR>
