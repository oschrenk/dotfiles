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
  \ nnoremap <silent> <leader>/ :execute 'Rg ' . input('Rg/')<CR>
Shortcut fzf | Search Git files
  \ noremap <Leader>o :GFiles<CR>
Shortcut fzf | Search files
  \ noremap <Leader>O :Files<CR>
Shortcut fzf | Search Tags
  \ noremap <Leader>T :Tags<CR>
Shortcut fzf | Search Old files and buffers
  \ noremap <Leader>H :History<CR>
Shortcut fzf | Search Marks
  \ noremap <Leader>m :Marks<CR>
Shortcut fzf | Search Commits for current buffer
  \ noremap <Leader>c :BCommits<CR>
Shortcut fzf | Search Commits
  \ noremap <Leader>C :Commits<CR>
Shortcut fzf | Search Lines in current buffer
  \ noremap <Leader>B :BLines<CR>
