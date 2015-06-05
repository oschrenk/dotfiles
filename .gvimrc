" ============================
" Look and Feel
" ============================
colorscheme iawriter
set linespace=5
set background=light
set guifont=Cousine:h16 " http://www.google.com/webfonts/specimen/Cousine
set shortmess+=I
set guioptions-=r

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
autocmd VimEnter BufRead,BufNewFile startinsert

