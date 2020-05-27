" ---------------------------
" goyo.vim
" ---------------------------
let g:goyo_width=70
let g:goyo_height='100%'

function! s:goyo_enter()
  " Quit Vim if this is the only remaining buffer
  let b:quitting = 0
  let b:quitting_bang = 0
  autocmd QuitPre <buffer> let b:quitting = 1
  cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!

  " dont split words on linebreak
  set linebreak
endfunction

function! s:goyo_leave()
  " Quit Vim if this is the only remaining buffer
  if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
    if b:quitting_bang
      qa!
    else
      qa
    endif
  endif
endfunction

autocmd! User GoyoEnter call <SID>goyo_enter()
autocmd! User GoyoLeave call <SID>goyo_leave()

source ~/.config/nvim/plugged/vim-shortcut/plugin/shortcut.vim

Shortcut goyo | toggle distraction-free writing mode
  \ nnoremap <silent> <space>tv :Goyo<CR>
