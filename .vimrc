set shell=bash\ --norc
set encoding=utf8         " how vim represents characters internally
set termencoding=utf-8    " used to display

" Automatic installation:
if empty(glob('~/.vim/autoload/plug.vim'))
		silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
		\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
		autocmd VimEnter * PlugInstall
endif

" vim-plug
call plug#begin('~/.vim/plugged')

" Startup
Plug 'EinfachToll/DidYouMean'             "  asks for the right file to open if ambigous

" tmux
Plug 'christoomey/vim-tmux-navigator'     " Navigate over tmux panes and vim splits
Plug 'tmux-plugins/vim-tmux-focus-events' " restore autocommand events within tmux eg. gitgutter refreshs
Plug 'epeli/slimux'                       " interact with tmux panes from within vim

" External Tools
Plug 'rizzatti/dash.vim'                  " Search Dash.app from Vim

" Navigation
Plug 'Shougo/unite.vim'                   " unified source to display search results
Plug 'Shougo/neomru.vim'                  " include unite.vim MRU sources
Plug 'Shougo/vimproc.vim', { 'do': 'make' } " Interactive command execution
Plug 'tpope/vim-vinegar'                  " netrw enhancements
Plug 'rking/ag.vim'                       " front for ag, a.k.a. the_silver_searcher

" Comments
Plug 'tpope/vim-commentary'               " Comment stuff. Use gcc on line, gc on visual block

" Completion
Plug 'Valloric/YouCompleteMe', { 'on': [], 'do': './install.sh --clang-completer' }

" Control
Plug 'tpope/vim-surround'                 " quote/parenthesize the surrounded code
Plug 'vim-scripts/paredit.vim'            " maintain the balanced state of matched parentheses
Plug 'tpope/vim-endwise',                 { 'for': 'ruby' } " end things automatically, like end after `if, do, def` in Ruby
Plug 'godlygeek/tabular'                  " align text

" lazy load ycm/ultisnips when entering insert mode
augroup load_ycm
  autocmd!
  autocmd InsertEnter * call plug#load('YouCompleteMe')
                     \| call youcompleteme#Enable() | autocmd! load_ycm
augroup END

" Git
Plug 'tpope/vim-fugitive'                 " git client for vim
Plug 'airblade/vim-gitgutter'             " mark modified, changed, deleted lines
Plug 'tpope/vim-repeat'                   " enable repeating for some plugins eg. vim-gitgutter

" File types
Plug 'dag/vim-fish',                      { 'for': 'fish' }
Plug 'derekwyatt/vim-scala',              { 'for': ['scala', 'markdown'] }
Plug 'guns/vim-clojure-static',           { 'for': 'clojure' }
Plug 'fwolanski/vim-clojure-conceal',     { 'for': 'clojure' }
Plug 'tpope/vim-fireplace',               { 'for': 'clojure' }
Plug 'tpope/vim-fireplace',               { 'for': 'clojure' }
Plug 'rodjek/vim-puppet',                 { 'for': 'puppet' }
Plug 'vim-ruby/vim-ruby',                 { 'for': 'ruby' }
Plug 'dag/vim2hs',                        { 'for': 'haskell' }
Plug 'tpope/vim-markdown',                { 'for': 'markdown' }
Plug 'itspriddle/vim-marked',             { 'for': 'markdown' } " open in Marked.app
Plug 'timcharper/textile.vim',            { 'for': 'textile' }
Plug 'Tyilo/applescript.vim',             { 'for': 'applescript' }

" Look and feel
Plug 'bling/vim-airline'                  " powerline statusline
Plug 'edkolev/tmuxline.vim'               " tmux statusline generator, share colors, settings
Plug 'raymond-w-ko/vim-niji'              " colored parentheses
Plug 'junegunn/goyo.vim', {'on': 'Goyo'}  " distraction free editing
Plug 'junegunn/limelight.vim', {'on': 'Limelight'} " focus on paragraphs

" Themes
Plug 'morhetz/gruvbox'
Plug 'jacekd/vim-iawriter'

call plug#end()
"End Plug --------------------

" ============================
" Look and Feel
" ============================

set background=dark
colorscheme gruvbox

" ============================
" Keyboard mappings
" ============================

" map leader to <space>
let mapleader = " "

" escape with jk
inoremap jk <Esc>

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

" Jump back to last edited buffer
nnoremap <C-p> :e#<CR>
inoremap <C-p> <esc>:e#<CR>

" move cursors naturally
nnoremap j gj
nnoremap k gk

" quickly move to beginning/end of line
nnoremap H 0
nnoremap L $

" Ctrl+q: Closes the window
nnoremap <c-q> :q<cr>

" Ctrl+s: Save the file
nnoremap <c-s> :w<cr>

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

set autoread

set title                     " show title in console title bar.
set cursorline                " highlights line
set cursorcolumn              " highlights column
set number                    " show line number

set splitright                " always split to the right
set splitbelow                " always split to the bottom

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

" Centralize backups, swap files, and persistent undo
set directory=~/.vim/tmp      " Set temp directory (don't litter local dir with swp/tmp files)
set nobackup                  " Get rid of backups, I don't use them
set nowb                      " Get rid of backups on write
set noswapfile                " Get rid of swp files, I have never used them
if exists("&undodir")
    set undofile              " Persistent undo! Pure money.
    let &undodir=&directory
    set undolevels=500
    set undoreload=500
endif

" Reload when entering buffer or gaining focus
au FocusGained,BufEnter * :silent! !
"
" " Autosave on focus lost or when exiting the buffer
au FocusLost,WinLeave * :silent! w

" Auto-Delete trailing whitspace
autocmd BufWritePre *.* :%s/\s\+$//e

" when commiting  add new line and enter insert mode
au FileType gitcommit startinsert

" Jump to last cursor position when opening a file
autocmd BufReadPost * call s:SetCursorPosition()
function! s:SetCursorPosition()
    if &filetype !~ 'svn\|commit\c'
        if line("'\"") > 0 && line("'\"") <= line("$")
            exe "normal! g`\""
            normal! zz
        endif
    end
endfunction

" ============================
" Plugin configuration
" ============================

" ---------------------------
" dash.vim
" ---------------------------
:nmap <silent> <leader>d <Plug>DashSearch

" ---------------------------
" paredit.vim
" ---------------------------
let g:paredit_leader=','                    " set the leader
let g:paredit_shortmaps=0                   " force disabling the shortmaps

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

" File searching using <leader>f
" -no-split to open as modal dialog
" -start-insert to start in insert mode
nnoremap <silent> [unite]f :<C-u>Unite -no-split -start-insert -buffer-name=files -profile-name=buffer file_rec/async:!<cr>

" Grepping using <leader>/
nnoremap <silent> [unite]/ :<C-u>Unite -buffer-name=search grep:.<cr>

" Yank history using <leader>y
let g:unite_source_history_yank_enable = 1
nnoremap <silent> [unite]y :<C-u>Unite -no-split -buffer-name=yank history/yank:<cr>

" MRU files using <leader>r
nnoremap <silent> [unite]r :<C-u>Unite -no-split -buffer-name=mru -start-insert neomru/file<cr>

" ag > ack > grep
if executable('ag')

" The silver searcher. Ignore .gitignore and search everything.
" Smart case, ignore vcs ignore files, and search hidden.
let s:ag_opts = '--smart-case --hidden --depth 15 --nocolor --nogroup '.
		\ '--ignore ".git" '.
		\ '--ignore ".ivy2" '.
		\ '--ignore ".m2" '.
		\ '--ignore ".rbenv" '.
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

" ===========================
" Spellcheck
" ===========================
set spelllang=en
set spellfile=$HOME/.vim/spell/en.utf-8.add " spellcheck dictionary location
set complete+=kspell                        " word comletion via ctrl n/p
autocmd FileType gitcommit setlocal spell   " spellcheck git commit messages
autocmd FileType markdown  setlocal spell   " spelllcheck markdown files

