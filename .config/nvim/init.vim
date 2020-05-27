set shell=fish
set encoding=utf8         " how vim represents characters internally
set termencoding=utf-8    " used to display
set termguicolors

" ============================
" Plugins
" ============================

source ~/.config/nvim/plugins.vim

" ============================
" Look and Feel
" ============================

set laststatus=0                  " hide statusbar
set background=dark
colorscheme gruvbox
let g:gruvbox_sign_column = 'bg0'

" ============================
" Config, Global
" ============================
"
source ~/.config/nvim/settings.vim

" ============================
" Plugin configuration
" ============================

source ~/.config/nvim/settings.echo-doc.vim
source ~/.config/nvim/settings.coc.vim
source ~/.config/nvim/settings.fzf.vim
source ~/.config/nvim/settings.rainbow_parentheses.vim
source ~/.config/nvim/settings.goyo.vim
source ~/.config/nvim/settings.netrw.vim
source ~/.config/nvim/settings.projectionist.vim

" ============================
" Keyboard mappings
" ============================

" need to source manually
source ~/.config/nvim/plugged/vim-shortcut/plugin/shortcut.vim

" map leader to <space>
let mapleader = "\<Space>"

" Do not enter Ex mode by accident
nnoremap Q <Nop>

" Disable arrow keys
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>
nnoremap <Left> <nop>
nnoremap <Right> <nop>
nnoremap <Up> <nop>
noremap <Down> <nop>

" Jump back to last edited buffer
Shortcut repeat the last macro
  \ nnoremap <C-p> :e#<CR>
  \ inoremap <C-p> <esc>:e#<CR>

" move cursors naturally
nnoremap j gj
nnoremap k gk

" quickly move to end of line
nnoremap L $

" <space>+w: Save the file
nnoremap <Leader>w :w<cr>

" U: Redos since 'u' undos
nnoremap U :redo<cr>

" N: Find next occurrence backward
nnoremap N Nzzzv

Shortcut repeat the last macro
  \ nnoremap , @@

" Use <C-c> to clear the highlighting of :set hlsearch.
if maparg('<C-c>', 'n') ==# ''
  nnoremap <silent> <C-c> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif

Shortcut show shortcut menu and run chosen shortcut
  \ noremap <silent> <Leader><Leader> :Shortcuts<Return>

Shortcut fallback to shortcut menu on partial entry
  \ noremap <silent> <Leader> :Shortcuts<Return>

" Aerojump
Shortcut Aerojump Space
  \ nmap <Leader>as <Plug>(AerojumpSpace)
Shortcut Aerojump Bolt
  \ nmap <Leader>as <Plug>(AerojumpBolt)
Shortcut Aerojump From Cursor Bolt
  \ nmap <Leader>aa <Plug>(AerojumpFromCursorBolt)
Shortcut Aerojump Default
  \ nmap <Leader>ad <Plug>(AerojumpDefault)

" FZF
Shortcut FZF Search text
  \ nnoremap <silent> <leader>/ :execute 'Rg ' . input('Rg/')<CR>
Shortcut FZF Search Git files
  \ noremap <Leader>o :GFiles<CR>
Shortcut FZF Search files
  \ noremap <Leader>O :Files<CR>
Shortcut FZF Search Tags
  \ noremap <Leader>t :Tags<CR>
Shortcut FZF Search Old files and buffers
  \ noremap <Leader>H :History<CR>
Shortcut FZF Search Marks
  \ noremap <Leader>m :Marks<CR>
Shortcut FZF Search Commits for current buffer
  \ noremap <Leader>c :BCommits<CR>
Shortcut FZF Search Commits
  \ noremap <Leader>C :Commits<CR>
Shortcut FZF Search Lines in current buffer
  \ noremap <Leader>B :BLines<CR>

" COC
Shortcut COC Rename current word
  \ nmap <leader>rn <Plug>(coc-rename)

Shortcut COC format selected region
  \ xmap <leader>f  <Plug>(coc-format-selected)
  \ nmap <leader>f  <Plug>(coc-format-selected)

Shortcut COC do codeAction of selected region, ex: `<leader>aap` for current paragraph
  \ xmap <leader>a  <Plug>(coc-codeaction-selected)
  \ nmap <leader>a  <Plug>(coc-codeaction-selected)

Shortcut COC do codeAction of current line
  \ nmap <leader>ac  <Plug>(coc-codeaction)

Shortcut COC Fix autofix problem of current line
  \ nmap <leader>qf  <Plug>(coc-fix-current)

" Create mappings for function text object, requires document symbols feature of languageserver.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <C-d> for select selections ranges, needs server support, like: coc-tsserver, coc-python
nmap <silent> <C-d> <Plug>(coc-range-select)
xmap <silent> <C-d> <Plug>(coc-range-select)
" Using CocList
"
Shortcut COC Show all diagnostics
  \ nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
Shortcut COC Manage extensions
  \ nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
Shortcut COC Show commands
  \ nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

Shortcut COC Use <c-space> to trigger completion
  \ inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Or use `complete_info` if your vim support it, like:
" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[g` and `]g` to navigate diagnostics
Shortcut COC previous diagnostic
  \ nmap <silent> [g <Plug>(coc-diagnostic-prev)
Shortcut COC next diagnostic
  \ nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Remap keys for gotos
Shortcut COC goto definition
  \ nmap <silent> gd <Plug>(coc-definition)
Shortcut COC goto type definition
  \ nmap <silent> gy <Plug>(coc-type-definition)
Shortcut COC goto implementation
  \ nmap <silent> gi <Plug>(coc-implementation)
Shortcut COC goto references
  \ nmap <silent> gr <Plug>(coc-references)

Shortcut COC show documentation in preview window
  \ nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" ===========================
" Spellcheck
" ===========================
set spelllang=en
set spellfile=$HOME/.config/nvim/spell/en.utf-8.add " spellcheck dictionary location
set complete+=kspell                        " word comletion via ctrl n/p
autocmd FileType gitcommit setlocal spell   " spellcheck git commit messages
autocmd FileType markdown  setlocal spell   " spelllcheck markdown filetypes
autocmd FileType tasks setlocal spell       " spelllcheck tasks filetypes

" ===========================
" Templates
" ===========================

nnoremap ,html :-1read $HOME/.config/nvim/templates/index.html<CR>3jwf>a

" ===========================
" Auto corrections
" ===========================

iab xtoday <c-r>=strftime("%Y%m%d")<cr>
iab xtime <c-r>=strftime("%H:%M")<cr>
iab xnow <c-r>=strftime("%Y%m%d %H:%M")<cr>

iab soem some
iab teh the
iab tommorow tomorrow
iab tommorrow tomorrow

