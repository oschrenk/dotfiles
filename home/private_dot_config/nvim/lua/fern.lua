-- ============================
-- Fern
-- ============================

vim.api.nvim_exec(
[[
let g:fern#disable_default_mappings   = 1
" let g:fern#disable_drawer_auto_quit   = 1
" let g:fern#disable_viewer_hide_cursor = 1
let g:fern#renderer = "nerdfont"

noremap <silent> - :Fern . -reveal=% -drawer -width=35 -toggle -right<CR><C-w>=

function! FernInit() abort
  nmap <buffer><expr>
        \ <Plug>(fern-my-open-expand-collapse)
        \ fern#smart#leaf(
        \   "\<Plug>(fern-action-open:select)",
        \   "\<Plug>(fern-action-expand)",
        \   "\<Plug>(fern-action-collapse)",
        \ )
  nmap <buffer> <CR> <Plug>(fern-my-open-expand-collapse)
  nmap <buffer> m <Plug>(fern-action-mark:toggle)j
  nmap <buffer> N <Plug>(fern-action-new-file)
  nmap <buffer> K <Plug>(fern-action-new-dir)
  nmap <buffer> D <Plug>(fern-action-remove)
  nmap <buffer> C <Plug>(fern-action-move)
  nmap <buffer> R <Plug>(fern-action-rename)
  nmap <buffer> r <Plug>(fern-action-reload)
  nmap <buffer> <nowait> d <Plug>(fern-action-hidden:toggle)
endfunction

augroup FernEvents
  autocmd!
  autocmd FileType fern call FernInit()
augroup END

augroup FernTypeGroup
    autocmd! * <buffer>
    autocmd BufEnter <buffer> silent execute "normal \<Plug>(fern-action-reload)"
augroup END

function! s:on_highlight() abort
  " Use brighter highlight on root node
  highlight link FernRootSymbol Title
  highlight link FernRootText   Title
endfunction

augroup my-fern-highlight
  autocmd!
  autocmd User FernHighlight call s:on_highlight()
augroup END
]],
false)

-- typescript,js, tsx not playing well
-- " autocmd BufEnter *.{ts} :syntax sync fromstart
-- " autocmd BufLeave *.{ts} :syntax sync clear
-- " autocmd BufEnter *.{js} :syntax sync fromstart
-- " autocmd BufLeave *.{js} :syntax sync clear
-- " autocmd BufEnter *.{jsx,tsx} :syntax sync fromstart
-- " autocmd BufLeave *.{jsx,tsx} :syntax sync clear

