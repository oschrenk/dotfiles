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

NeoBundle 'kien/ctrlp.vim'
NeoBundle 'tpope/vim-surround'
NeoBundle 'Shougo/vimshell', { 'rev' : '3787e5' }
NeoBundle 'godlygeek/tabular'
NeoBundle 'ervandew/supertab'
NeoBundle 'sjl/gundo.vim'

" Git
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'airblade/vim-gitgutter'

" Syntax
NeoBundle 'derekwyatt/vim-scala'

NeoBundle 'jtratner/vim-flavored-markdown'
augroup markdown
    au!
    au BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
augroup END

NeoBundle 'vim-ruby/vim-ruby'
NeoBundle 'dag/vim2hs'
NeoBundle 'scrooloose/syntastic'

" Look and feel
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
syntax on                          " syntax highlighting
syntax enable

set title                          " show title in console title bar.
set cursorline                     " highlights line
set cursorcolumn                   " highlights column
set guitablabel=%t                 " Tab headings
set guitabtooltip=%F               " Tab headings
set number relativenumber          " read number_relativenumber
set lsp=0                          " space it out a little more (easier to read)
set cmdheight=1                    " the command bar is 2 high.

set autoindent
set smartindent
set showmode                       " show current-mode
set showcmd                        " show partially-typed commands
set wildmenu                       " visual autocomplete for command menu
set lazyredraw                     " redraw only when we need to
set showmatch                      " show matching brackets

set guifont=Meslo\ LG\ S\ DZ\ Regular\ for\ Powerline  " For powerline font in MacVim
set encoding=utf-8                 " Necessary to show Unicode glyphs
set fillchars+=stl:\ ,stlnc:\
set term=xterm-256color
set termencoding=utf-8
set rtp+=/usr/local/lib/python2.7/site-packages/powerline/bindings/vim/
set laststatus=2                   " Always show statusline
set t_Co=256                       " Use 256 colours (Use this setting only if your terminal supports 256 colours)
