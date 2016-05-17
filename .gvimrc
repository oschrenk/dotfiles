" ============================
" Look and Feel
" ============================
colorscheme iawriter

set linespace=10
set background=light
set guifont=Cousine:h20 " http://www.google.com/webfonts/specimen/Cousine

set fullscreen           " set fullscreen on startup
set shortmess+=I         " don't give the intro message when starting Vim
set guioptions-=r        " Remove right-hand scrollbar
set guicursor=n:blinkon0 " Don’t blink cursor in normal mode

function! s:goyo_enter()
  set noshowmode
  set noshowcmd
  set noruler
  set cursorline!
  set cursorcolumn!
  set scrolloff=999
  set laststatus=0
  Limelight
endfunction

function! s:goyo_leave()
  set showmode
  set showcmd
  set ruler
  set cursorline!
  set cursorcolumn!
  set scrolloff=5
  set laststatus=2
  Limelight!
endfunction

autocmd! User GoyoEnter
autocmd! User GoyoLeave
autocmd  User GoyoEnter nested call <SID>goyo_enter()
autocmd  User GoyoLeave nested call <SID>goyo_leave()

autocmd VimEnter * Goyo 45%x65%+5%
autocmd VimEnter * setlocal spell
autocmd VimEnter * set nolist wrap linebreak
autocmd VimEnter BufRead,BufNewFile startinsert

