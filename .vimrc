set shell=bash\ --norc
set termencoding=

"NeoBundle Scripts-----------------------------
if has('vim_starting')
  set nocompatible               " Be iMproved

  " Required:
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('~/.vim/bundle'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" My Bundles here:
"
" Control
" Resize vim
map <c-J> :resize -5<cr>
map <c-K> :resize +5<cr>
map <c-H> :vertical resize -5<cr>
map <c-L> :vertical resize +5<cr>

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

" Base Bundles
NeoBundle 'chrisbra/Recover.vim'
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'tpope/vim-surround'
NeoBundle 'ervandew/supertab'
NeoBundle 'vim-scripts/paredit.vim'
NeoBundle 'Townk/vim-autoclose'
let g:AutoClosePairs_add = "<> | \' \""

" Navigation
NeoBundle 'Lokaltog/vim-easymotion'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'tpope/vim-vinegar'
NeoBundle 'terryma/vim-expand-region'

" Git
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'airblade/vim-gitgutter'

" Languages
NeoBundle 'dag/vim-fish'
NeoBundle 'derekwyatt/vim-scala'
NeoBundle 'guns/vim-clojure-static'

NeoBundle 'jtratner/vim-flavored-markdown'
augroup markdown
    au!
    au BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
augroup END

" Search
NeoBundle 'rking/ag.vim'

NeoBundle 'vim-ruby/vim-ruby'
NeoBundle 'dag/vim2hs'
NeoBundle 'scrooloose/syntastic'

" Look and feel
set rtp+=/usr/local/lib/python2.7/site-packages/powerline/bindings/vim/
NeoBundle 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
NeoBundle 'kien/rainbow_parentheses.vim'

NeoBundle 'morhetz/gruvbox'
call pathogen#infect()
set background=dark
colorscheme gruvbox

" Required:
call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck
"End NeoBundle Scripts-------------------------

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

set showmode                  " show current-mode
set showcmd                   " show partially-typed commands
set wildmenu                  " visual autocomplete for command menu
set lazyredraw                " redraw only when we need to
set showmatch                 " show matching brackets

set hlsearch                  " Highlight search matches
set incsearch                 " Highlight search matches as you type
set ignorecase                " Ignore case when searching
set smartcase                 " Ignore case if pattern is lowercase, case-sensitive otherwise

" Quickly edit and source your .vimrc
nmap <silent> <leader>ev :tabnew $MYVIMRC<CR>
nmap <silent> <leader>es :so $MYVIMRC<CR>

" Reload when entering buffer or gaining focus
au FocusGained,BufEnter * :silent! !
"
" " Autosave on focus lost or when exiting the buffer
au FocusLost,WinLeave * :silent! w

""" Powerline """
source /usr/local/lib/python2.7/site-packages/powerline/bindings/vim/plugin/powerline.vim
set fillchars+=stl:\ ,stlnc:\
set laststatus=2              " Always show statusline

au VimEnter * RainbowParenthesesActivate
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

""" Commands
" Delete trailing whitspace
autocmd BufWritePre *.* :%s/\s\+$//e
