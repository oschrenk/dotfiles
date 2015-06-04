" font
set guifont=M+\ 1mn\ light\ for\ Powerline:h20
set background=dark
set shortmess+=I

set guioptions-=r

function! s:goyo_enter()
  silent !tmux set status off
  set noshowmode
  set noshowcmd
  set noruler
  set scrolloff=999
  set laststatus=0
  Limelight
endfunction

function! s:goyo_leave()
  silent !tmux set status on
  set showmode
  set showcmd
  set ruler
  set scrolloff=5
  set laststatus=2
  Limelight!
endfunction

autocmd! User GoyoEnter
autocmd! User GoyoLeave
autocmd  User GoyoEnter nested call <SID>goyo_enter()
autocmd  User GoyoLeave nested call <SID>goyo_leave()

autocmd VimEnter * Goyo
autocmd VimEnter BufRead,BufNewFile startinsert

