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
Plug 'Shougo/unite.vim'               " unified source to display search results
Plug 'christoomey/vim-tmux-navigator' " Navigate over tmux panes and vim splits

" Git
Plug 'tpope/vim-fugitive'             " git client for vim
Plug 'airblade/vim-gitgutter'         " mark modified, changed, deleted lines

" file types
Plug 'dag/vim-fish'                   " fish shell
Plug 'derekwyatt/vim-scala'           " scala
Plug 'guns/vim-clojure-static'        " clojure
Plug 'vim-ruby/vim-ruby'              " ruby
Plug 'dag/vim2hs'                     " haskell
Plug 'jtratner/vim-flavored-markdown' " markdown

" Search
Plug 'rking/ag.vim'
Plug 'scrooloose/syntastic'

" Look and feel
Plug 'bling/vim-airline'             " powerline statusline
Plug 'morhetz/gruvbox'               " theme
Plug 'kien/rainbow_parentheses.vim'  " colored parentheses

call plug#end()
"End Plug --------------------

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
" Config
" ============================
"
syntax on                     " syntax highlighting
syntax enable                 " syntac highlighting

set title                     " show title in console title bar.
set cursorline                " highlights line
set cursorcolumn              " highlights column
set number                    " show line number

set splitright                " always split to the right
set splitbelow                " always split to the bottom
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

set autoread                  " Set to auto read when a file is changed from the outside
set clipboard=unnamed         " gain access to clipboard in OS X

" Reload when entering buffer or gaining focus
au FocusGained,BufEnter * :silent! !
"
" " Autosave on focus lost or when exiting the buffer
au FocusLost,WinLeave * :silent! w

" Auto-Delete trailing whitspace
autocmd BufWritePre *.* :%s/\s\+$//e

" Source the vimrc file after saving it
if has("autocmd")
  autocmd bufwritepost .vimrc source $MYVIMRC
endif

" ============================
" Plugin configuration
" ============================

" Unite
" ---------------------------
nnoremap <C-p> :Unite file_rec/async<cr>

" Airline
let g:airline_powerline_fonts = 1
set laststatus=2

" RainbowParentheses
au VimEnter * RainbowParenthesesActivate
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

" Markdown
augroup markdown
    au!
    au BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
augroup END
