set shell=bash\ --norc
set termencoding=

" vim-plug
call plug#begin('~/.vim/plugged')

" Base Bundles
Plug 'chrisbra/Recover.vim'
Plug 'kien/ctrlp.vim'
Plug 'tpope/vim-surround'
Plug 'ervandew/supertab'
Plug 'vim-scripts/paredit.vim'
Plug 'Townk/vim-autoclose'
let g:AutoClosePairs_add = "<> | \' \""

" Navigation
Plug 'Lokaltog/vim-easymotion'
Plug 'Shougo/unite.vim'
Plug 'tpope/vim-vinegar'
Plug 'terryma/vim-expand-region'
Plug 'christoomey/vim-tmux-navigator'

" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Languages
Plug 'dag/vim-fish'
Plug 'derekwyatt/vim-scala'
Plug 'guns/vim-clojure-static'
Plug 'vim-ruby/vim-ruby'
Plug 'dag/vim2hs'

Plug 'jtratner/vim-flavored-markdown'
augroup markdown
    au!
    au BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
augroup END

" Search
Plug 'rking/ag.vim'
Plug 'scrooloose/syntastic'

" Look and feel
Plug 'bling/vim-airline'
Plug 'morhetz/gruvbox'
Plug 'kien/rainbow_parentheses.vim'


call plug#end()
"End Plug -------------------------

set background=dark
colorscheme gruvbox
" ============================
" Keyboard
" ============================

" im too lazy to press shift
nnoremap ; :

" move cursors naturally
nnoremap j gj
nnoremap k gk

" quickly move to beginning/end of line
nnoremap H 0
nnoremap L $

" Use jk to exit insert mode
set timeout timeoutlen=400 ttimeoutlen=100
set <f13>=jk
imap <F13> <esc>

" Disable arrow keys
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>

" ============================
" Plugin configuration
" ============================

nnoremap <C-p> :Unite file_rec/async<cr>

" ============================
" Config
" ============================
"
syntax on                     " syntax highlighting
syntax enable

set title                     " show title in console title bar.
set cursorline                " highlights line
set cursorcolumn              " highlights column
set number
set guitablabel=%t            " Tab headings
set guitabtooltip=%F          " Tab headings
set lsp=0                     " space it out a little more (easier to read)
set cmdheight=1               " the command bar is 2 high.

set autoindent
set smartindent
set expandtab                 " <TAB> will insert 'softtabstop' spaces
set tabstop=2
set shiftwidth=2
set softtabstop=2

set backspace=2               " make backspace work like most other app

set showmode                  " show current-mode
set showcmd                   " show partially-typed commands
set wildmenu                  " visual autocomplete for command menu
set lazyredraw                " redraw only when we need to
set showmatch                 " show matching brackets

set hlsearch                  " Highlight search matches
set incsearch                 " Highlight search matches as you type
set ignorecase                " Ignore case when searching
set smartcase                 " Ignore case if pattern is lowercase, case-sensitive otherwise

set clipboard=unnamed         " gain access to clipboard in OS X

" Quickly edit and source your .vimrc
nmap <silent> <leader>ev :tabnew $MYVIMRC<CR>
nmap <silent> <leader>es :so $MYVIMRC<CR>

" Reload when entering buffer or gaining focus
au FocusGained,BufEnter * :silent! !
"
" " Autosave on focus lost or when exiting the buffer
au FocusLost,WinLeave * :silent! w

" Airline
let g:airline_powerline_fonts = 1
set laststatus=2

au VimEnter * RainbowParenthesesActivate
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

""" Commands
" Delete trailing whitspace
autocmd BufWritePre *.* :%s/\s\+$//e
