" font
set guifont=M+\ 1mn\ light\ for\ Powerline:h16
set background=dark
set shortmess+=I

let s:hidden_all = 0
function! ToggleHiddenAll()
    if s:hidden_all  == 0
        let s:hidden_all = 1
        set noshowmode
        set noruler
        set laststatus=0
        set noshowcmd
    else
        let s:hidden_all = 0
        set showmode
        set ruler
        set laststatus=2
        set showcmd
    endif
endfunction

nnoremap <S-h> :call ToggleHiddenAll()<CR>
nnoremap <S-h> :call ToggleHiddenAll()<CR>et g:airline_powerline_fonts=1
