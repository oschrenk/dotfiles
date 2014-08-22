set shell=bash\ --norc

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
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'flazz/vim-colorschemes'
NeoBundle 'jtratner/vim-flavored-markdown'

" You can specify revision/branch/tag.
NeoBundle 'Shougo/vimshell', { 'rev' : '3787e5' }

" Required:
call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck
"End NeoBundle Scripts-------------------------

" my stuff
syntax on
=======
execute pathogen#infect()
filetype plugin indent on

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
