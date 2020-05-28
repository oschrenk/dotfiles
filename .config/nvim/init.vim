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

source ~/.config/nvim/settings.aerojump.vim
source ~/.config/nvim/settings.coc.vim
source ~/.config/nvim/settings.echo-doc.vim
source ~/.config/nvim/settings.fzf.vim
source ~/.config/nvim/settings.goyo.vim
source ~/.config/nvim/settings.limelight.vim
source ~/.config/nvim/settings.netrw.vim
source ~/.config/nvim/settings.projectionist.vim
source ~/.config/nvim/settings.rainbow_parentheses.vim
source ~/.config/nvim/settings.textobj.vim
source ~/.config/nvim/settings.textobj.url.vim
source ~/.config/nvim/settings.vimwiki.vim

" ============================
" Keyboard mappings
" ============================


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

Shortcut shortcut | Show shortcut menu and run chosen shortcut
  \ noremap <silent> <Leader><Leader> :Shortcuts<Return>

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
iab xToday <c-r>=strftime("%Y-%m-%d")<cr>
iab xtime <c-r>=strftime("%H:%M")<cr>
iab xnow <c-r>=strftime("%Y%m%d %H:%M")<cr>

iab soem some
iab teh the
iab tommorow tomorrow
iab tommorrow tomorrow

