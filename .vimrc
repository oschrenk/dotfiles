set shell=bash\ --norc
set termencoding=

" vim-plug
call plug#begin('~/.vim/plugged')

" Base
Plug 'chrisbra/Recover.vim'

" Navigation
Plug 'Shougo/unite.vim'                      " unified source to display search results
Plug 'Shougo/vimproc.vim', { 'do': 'make' }  " Interactive command execution
Plug 'christoomey/vim-tmux-navigator'        " Navigate over tmux panes and vim splits

" Motion
Plug 'justinmk/vim-sneak'                    " jump to any location with two chars

" Control & Completion
Plug 'tpope/vim-surround'
Plug 'ervandew/supertab'
Plug 'vim-scripts/paredit.vim'
Plug 'scrooloose/syntastic'

" Git
Plug 'tpope/vim-fugitive'             " git client for vim
Plug 'airblade/vim-gitgutter'         " mark modified, changed, deleted lines

" File types
Plug 'dag/vim-fish'                   " fish shell
Plug 'derekwyatt/vim-scala'           " scala
Plug 'guns/vim-clojure-static'        " clojure
Plug 'fwolanski/vim-clojure-conceal'  " clojure after syntax
Plug 'vim-ruby/vim-ruby'              " ruby
Plug 'dag/vim2hs'                     " haskell
Plug 'tpope/vim-markdown'             " markdown
Plug 'itspriddle/vim-marked'          " open markdown in Marked.app

" Search
Plug 'rking/ag.vim'

" Look and feel
Plug 'bling/vim-airline'             " powerline statusline
Plug 'morhetz/gruvbox'               " theme
Plug 'kien/rainbow_parentheses.vim'  " colored parentheses

call plug#end()
"End Plug --------------------

set background=dark
colorscheme gruvbox

" ============================
" Keyboard mappings
" ============================

" Disable arrow keys
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>

" move cursors naturally
nnoremap j gj
nnoremap k gk

" quickly move to beginning/end of line
nnoremap H 0
nnoremap L $

" Q: Closes the window
nnoremap Q :q<cr>

" W: Save
nnoremap W :w<cr>

" U: Redos since 'u' undos
nnoremap U :redo<cr>

" N: Find next occurrence backward
nnoremap N Nzzzv

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

" ---------------------------
" Unite
" ---------------------------
" space as prefix for unite
nmap <space> [unite]
nnoremap [unite] <nop>
let g:unite_data_directory = '~/.unite'

call unite#filters#matcher_default#use(['matcher_fuzzy'])
call unite#filters#sorter_default#use(['sorter_rank'])

" File searching using <space>f
" -no-split to open as model dialog
nnoremap <silent> [unite]f :<C-u>Unite -no-split -buffer-name=files -profile-name=buffer file_rec/async:!<cr>

" Grepping using <space>/
nnoremap <silent> [unite]/ :<C-u>Unite -buffer-name=search grep:.<cr>

" Yank history using <space>y
let g:unite_source_history_yank_enable = 1
nnoremap <silent> [unite]y :<C-u>Unite -no-split -buffer-name=yank history/yank:<cr>

" ag > ack > grep
if executable('ag')
  let g:unite_source_grep_command='ag'
  let g:unite_source_grep_default_opts =
        \ '--line-numbers --nocolor --nogroup --hidden ' .
        \ '--ignore ''.hg'' ' .
        \ '--ignore ''.svn'' ' .
        \ '--ignore ''.git'' ' .
        \ '--ignore ''.bzr'' ' .
        \ '--ignore ''**/*.pyc''  ' .
        \ '--ignore ''**/*.js.map'' ' .
        \ '--ignore ''**/*.iso'''
  let g:unite_source_grep_recursive_opt=''
  let g:unite_source_rec_async_command= 'ag --nocolor --nogroup -g ""'
elseif executable('ack')
  let g:unite_source_grep_command='ack'
  let g:unite_source_grep_default_opts='--no-heading --no-color -C4'
  let g:unite_source_grep_recursive_opt=''
endif

" ---------------------------
" Syntastic
" ---------------------------
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_enable_signs=1
let g:syntastic_loc_list_height=5

" ---------------------------
" Other
" ---------------------------
"
" vim-clojure-conceal
let g:clojure_conceal_extras=1   " fn, defn-, letfn, and #() to unicode symbols

" Airline
let g:airline_powerline_fonts = 1
set laststatus=2

" RainbowParentheses
au VimEnter * RainbowParenthesesActivate
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

" Markdown
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
let g:markdown_fenced_languages = ['clojure', 'javascript', 'scala', 'vim']

" configure Marked.app
let g:marked_app = "Marked"

