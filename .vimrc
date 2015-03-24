set shell=bash\ --norc
set encoding=utf8         " how vim represents characters internally
set termencoding=utf-8    " used to display

" vim-plug
call plug#begin('~/.vim/plugged')

" Base
Plug 'tpope/vim-repeat'                      " enable repeating for some plugins eg vim-gitgutter

" Navigation
Plug 'Shougo/unite.vim'                      " unified source to display search results
Plug 'Shougo/vimproc.vim', { 'do': 'make' }  " Interactive command execution
Plug 'christoomey/vim-tmux-navigator'        " Navigate over tmux panes and vim splits
Plug 'tpope/vim-vinegar'                     " netrw enhancements

" Comments
Plug 'tpope/vim-commentary'                  " Comment stuff.Use gcc on line,gc on visual block

" Motion
Plug 'justinmk/vim-sneak'                    " jump to any location with two chars

" Control & Completion
Plug 'tpope/vim-surround'
Plug 'ervandew/supertab'
Plug 'vim-scripts/paredit.vim'

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
Plug 'tpope/vim-markdown',            { 'for': 'markdown' }
Plug 'itspriddle/vim-marked',         { 'for': 'markdown' } " open markdown in Marked.app
Plug 'timcharper/textile.vim',        { 'for': 'textile' }

" Search
Plug 'rking/ag.vim'
Plug 'rizzatti/dash.vim'             " search for terms using Dash.app

" Tools & Externals
Plug 'xolox/vim-notes'               " manage notes
Plug 'xolox/vim-misc'                " dependency of vim-notes

" Look and feel
Plug 'bling/vim-airline'             " powerline statusline
Plug 'morhetz/gruvbox'               " theme
Plug 'amdt/vim-niji'                 " colored parentheses

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

" Use arrow keys resize viewports
nnoremap <Left> :vertical resize -1<CR>
nnoremap <Right> :vertical resize +1<CR>
nnoremap <Up> :resize -1<CR>
noremap <Down> :resize +1<CR>

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

" Use tab in normal mode to open vinegar
nmap <Tab> <Plug>VinegarUp

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
set autoindent                " copy indentation form last line
set smartindent               " automatically inserts one extra level in some cases

set expandtab                 " <TAB> will insert 'softtabstop' spaces
set tabstop=2                 " width of the <TAB> character
set shiftwidth=2              " affects >>, <<, ==
set softtabstop=2
set backspace=2               " make backspace work like most other app

if !&scrolloff
  set scrolloff=1             " ensure number of visible lines above/below cursor
endif
if !&sidescrolloff
  set sidescrolloff=5         " ensure number of visible columns left/right to cursor
endif
set display+=lastline         " show as much as possible from last line

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
set visualbell                " don't beep
set noerrorbells              " don't beep

set nobackup                  " do not create backup files
set noswapfile                " do not create swap files

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

" when commiting  add new line and enter insert mode
au FileType gitcommit execute "normal! O" | startinsert

" ============================
" Plugin configuration
" ============================

" vim-notes
let g:notes_directories = ['~/Documents/Notes']
let g:notes_title_sync = 'no'
let g:notes_suffix = '.md'
let g:notes_smart_quotes = 0

" ---------------------------
" netrw
" ---------------------------
let g:netrw_list_hide='\.o,\.obj,*~,\.pyc,' "stuff to ignore when tab completing
let g:netrw_list_hide.='\.git,'
let g:netrw_list_hide.='\.tmp,'
let g:netrw_list_hide.='\.bundle,'
let g:netrw_list_hide.='\.DS_Store,'
let g:netrw_list_hide.='\vendor/,'
let g:netrw_list_hide.='\.gem,'
let g:netrw_list_hide.='bin/,'
let g:netrw_list_hide.='target/,'
let g:netrw_list_hide.='log/,'
let g:netrw_list_hide.='tmp/,'
let g:netrw_list_hide.='\.idea/,'
let g:netrw_list_hide.='\.ico,\.png,\.jpg,\.gif,'
let g:netrw_list_hide.='\.so,\.swp,\.zip,/\.Trash/,\.pdf,\.dmg,/Library/,/\.rbenv/,'
let g:netrw_list_hide.='*/\.nx/**,*\.app'

" ---------------------------
" Unite
" ---------------------------
" space as prefix for unite
nmap <space> [unite]
nnoremap [unite] <nop>
let g:unite_data_directory = '~/.unite'

call unite#filters#matcher_default#use(['matcher_fuzzy'])
call unite#filters#sorter_default#use(['sorter_selecta'])

" File searching using <space>f
" -no-split to open as modal dialog
"  -start-insert to start in insert mode
nnoremap <silent> [unite]f :<C-u>Unite -no-split -start-insert -buffer-name=files -profile-name=buffer file_rec/async:!<cr>

" Grepping using <space>/
nnoremap <silent> [unite]/ :<C-u>Unite -buffer-name=search grep:.<cr>

" Yank history using <space>y
let g:unite_source_history_yank_enable = 1
nnoremap <silent> [unite]y :<C-u>Unite -no-split -buffer-name=yank history/yank:<cr>

" ag > ack > grep
if executable('ag')

" The silver searcher. Ignore .gitignore and search everything.
" Smart case, ignore vcs ignore files, and search hidden.
let s:ag_opts = '--smart-case --skip-vcs-ignores --hidden --depth 15 --nocolor --nogroup '.
		\ '--ignore ".git" '.
    \ '--ignore ''.hg'' ' .
    \ '--ignore ''.svn'' ' .
    \ '--ignore ''.bzr'' ' .
		\ '--ignore ".idea" '.
		\ '--ignore ".bundle" '.
		\ '--ignore "bin" '.
		\ '--ignore "cache" '.
		\ '--ignore "coverage" '.
		\ '--ignore "externs" '.
		\ '--ignore "javascripts" '.
		\ '--ignore "hicv" '.
		\ '--ignore "log" '.
		\ '--ignore "target" '.
		\ '--ignore "tmp" '.
		\ '--ignore "vendor" '.
		\ '--ignore "*.gif" '.
		\ '--ignore "*.ico" '.
		\ '--ignore "*.jar" '.
		\ '--ignore "*.jpg" '.
		\ '--ignore "*.log" '.
		\ '--ignore "*.png" '.
		\ '--ignore "*.ttf"'

  let g:unite_source_rec_async_command = 'ag --follow '.s:ag_opts.' -g ""'
  let g:unite_source_grep_command = 'ag'
	let g:unite_source_grep_default_opts = '--ignore-case --line-numbers '.s:ag_opts
	let g:unite_source_grep_recursive_opt = ''

elseif executable('ack')
  let g:unite_source_grep_command='ack'
  let g:unite_source_grep_default_opts='--no-heading --no-color -C4'
  let g:unite_source_grep_recursive_opt=''
endif

" ---------------------------
" Other
" ---------------------------
"
" vim-clojure-conceal
let g:clojure_conceal_extras=1   " fn, defn-, letfn, and #() to unicode symbols

" Airline
let g:airline_powerline_fonts = 1
set laststatus=2

" Markdown
au BufRead,BufNewFile *.md set filetype=markdown
let g:markdown_fenced_languages = ['clojure', 'javascript', 'scala', 'vim']

" configure Marked.app
let g:marked_app = "Marked"

" Spellcheck
set spelllang=en
set spellfile=$HOME/.vim/spell/en.utf-8.add " spellcheck dictionary location
autocmd FileType gitcommit setlocal spell   " spellcheck git commit messages
autocmd FileType markdown  setlocal spell   " spelllcheck markdown files

