" ============================
" Look and Feel
" ============================
colorscheme iawriter
set linespace=8
set background=light
set guifont=Cousine:h16 " http://www.google.com/webfonts/specimen/Cousine

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

autocmd VimEnter * Goyo
autocmd VimEnter * setlocal spell
autocmd VimEnter BufRead,BufNewFile startinsert

