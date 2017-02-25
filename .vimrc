" would love to set it to `fish` but at least vim-fugitive's
" :Gblame doesn't work with it
set shell=bash\ --norc
set encoding=utf8         " how vim represents characters internally
set termencoding=utf-8    " used to display

set timeoutlen=1000 ttimeoutlen=20

set t_8f=[38;2;%lu;%lu;%lum
set t_8b=[48;2;%lu;%lu;%lum
set termguicolors

" Automatic plug installation:
if empty(glob('~/.vim/autoload/plug.vim'))
		silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
		\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
		autocmd VimEnter * PlugInstall
endif

" vim-plug
call plug#begin('~/.vim/plugged')

" Startup
Plug 'EinfachToll/DidYouMean'             "  asks for the right file to open if ambigous

" Externals
Plug 'rizzatti/dash.vim'                  " Dash
Plug 'glidenote/newdayone.vim'            " DayOne

" tmux
Plug 'christoomey/vim-tmux-navigator'     " Navigate over tmux panes and vim splits
Plug 'tmux-plugins/vim-tmux-focus-events' " restore autocommand events within tmux eg. gitgutter refreshs

" Navigation
Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
Plug 'oschrenk/vim-vinegar'               " netrw enhancements
Plug 'airblade/vim-rooter'                " auto sets working directory

" Completion
Plug 'Valloric/YouCompleteMe', { 'on': [], 'do': './install.py --clang-completer' }
" lazy load ycm when entering insert mode
augroup load_ycm
  autocmd!
  autocmd InsertEnter * call plug#load('YouCompleteMe')
                     \| call youcompleteme#Enable() | autocmd! load_ycm
augroup END

" Control
Plug 'tpope/vim-repeat'                   " enable repeating for some plugins eg. vim-gitgutter
Plug 'tpope/vim-surround'                 " quote/parenthesize the surrounded code
Plug 'tpope/vim-commentary'               " Comment stuff. Use gcc on line, gc on visual block
Plug 'vim-scripts/paredit.vim'            " maintain the balanced state of matched parentheses
Plug 'tpope/vim-abolish'                  " search for, substitute, and abbreviate multiple variants of a word, adds: crs (coerce to snake_case). MixedCase (crm), camelCase (crc), snake_case (crs), and UPPER_CASE (cru)
Plugin 'editorconfig/editorconfig-vim'    " maintain consistent coding styles between editors

" Motions
Plug 'terryma/vim-expand-region'          " expand/shrink selection

" Text objects
Plug 'kana/vim-textobj-user'              " create your own text-objects
Plug 'gilligan/textobj-gitgutter'         " ih for change-hunk text object
Plug 'kana/vim-textobj-line'              " al/il for current line
Plug 'sgur/vim-textobj-parameter'         " i,/a, for function parameter
Plug 'Julian/vim-textobj-variable-segment' " iv/av change variable segments
Plug 'mattn/vim-textobj-url'              " au/iu for url
Plug 'kana/vim-textobj-entire'            " ae/ie for entire buffer
Plug 'rhysd/vim-textobj-anyblock'         " ib/ab for Quotes, Parenthesis and braces

" Git
Plug 'tpope/vim-fugitive'                 " git client in vim
Plug 'airblade/vim-gitgutter'             " mark modified, changed, deleted lines

" File types
Plug 'dag/vim-fish',                      { 'for': 'fish' }
Plug 'derekwyatt/vim-sbt',                { 'for': 'sbt.scala' }           " sbt syntax
Plug 'derekwyatt/vim-scala',              { 'for': ['scala', 'markdown'] } " scala syntax
Plug 'mpollmeier/vim-scalaConceal',       { 'for': 'scala' }               " scala
Plug 'ensime/ensime-vim',                 { 'for': 'scala' }               " scala
Plug 'guns/vim-clojure-static',           { 'for': 'clojure' }
Plug 'fwolanski/vim-clojure-conceal',     { 'for': 'clojure' }
Plug 'rodjek/vim-puppet',                 { 'for': 'puppet' }
Plug 'vim-ruby/vim-ruby',                 { 'for': 'ruby' }
Plug 'tpope/vim-endwise',                 { 'for': 'ruby' }     " end things automatically, like end after `if, do, def` in Ruby
Plug 'dag/vim2hs',                        { 'for': 'haskell' }
Plug 'itspriddle/vim-marked',             { 'for': 'markdown' } " open in Marked.app
Plug 'timcharper/textile.vim',            { 'for': 'textile' }
Plug 'Tyilo/applescript.vim',             { 'for': 'applescript' }
Plug 'tmux-plugins/vim-tmux',             { 'for': 'tmux' }    " for .tmux.conf
Plug 'ekalinin/Dockerfile.vim'

" Look and feel
Plug 'bling/vim-airline'                  " powerline statusline
Plug 'kien/rainbow_parentheses.vim'       " colored parentheses
Plug 'nathanaelkane/vim-indent-guides'    " display indent levels
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

" map global leader
let mapleader = "\<Space>"

" map local leader
let maplocalleader = "\\"


" escape with jk
inoremap jk <Esc>

" Do not questionable Ex mode by accident
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

" Use arrow keys resize viewports
nnoremap <Left> <nop>
nnoremap <Right> <nop>
nnoremap <Up> <nop>
noremap <Down> <nop>

" Jump back to last edited buffer
nnoremap <C-p> :e#<CR>
inoremap <C-p> <esc>:e#<CR>

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

" Disable backups, swaps
set nobackup                  " Get rid of backups, I don't use them
set nowb                      " Get rid of backups on write
set noswapfile                " Get rid of swp files, I have never used them

" Keep undo history across sessions
" :help undo-persistence
if exists("+undofile")
  " create dir if it doesn't exist
  if isdirectory($HOME . '/.vim/undo') == 0
    :silent !mkdir -p ~/.vim/undo > /dev/null 2>&1
  endif
  " if path ends in two slashes, file name will use complete path
  " :help dir
  set undodir=~/.vim/undo//
  set undofile
  set undolevels=500
  set undoreload=500
endif

" change formatting behaviour
" I don't like vim autoinserting comments for me
" I would love to just use `set formatoptions-=ro` but since C file plugin is
" loaded after loading .vimrc, the behaviour is overwritten, so resorting to
" autocmd is necessary
" default is tcq
" r automatically insert comment leader after <enter> in INSERT
" o automatically insert comment loeader after o or O in NORMAL
" -= removes these options
autocmd BufNewFile,BufRead * setlocal formatoptions-=ro

" Reload when entering buffer or gaining focus
au FocusGained,BufEnter * :silent! !

" Autosave on focus lost or when exiting the buffer
au FocusLost,WinLeave * :silent! w

" Auto-Delete trailing whitspace
autocmd BufWritePre *.* :%s/\s\+$//e

" when commiting add new line and enter insert mode
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

" Jump to first character or column
noremap <silent> H :call FirstCharOrFirstCol()<cr>
function! FirstCharOrFirstCol()
  let current_col = virtcol('.')
  normal ^
  let first_char = virtcol('.')
  if current_col == first_char
    normal 0
  endif
endfunction

" ============================
" Plugin configuration
" ============================

" ---------------------------
" vim-ensime
" ---------------------------

autocmd BufWritePost *.scala silent :EnTypeCheck
au FileType scala nnoremap <localleader>tc :EnTypeCheck<CR>
au FileType scala nnoremap <localleader>df :EnDeclaration<CR>

" ---------------------------
" vim-indent-guides
" ---------------------------

" Indent lines at l 2
let g:indent_guides_start_level = 2

" ---------------------------
" fzf
" ---------------------------

nnoremap <silent> <leader>/ :execute 'Ag ' . input('Ag/')<CR>
noremap <Leader>f :GFiles<CR>
noremap <Leader>F :Files<CR>
noremap <Leader>t :Tags<CR>
noremap <Leader>h :History<CR>
noremap <Leader>m :Marks<CR>
noremap <Leader>c :BCommits<CR>
noremap <Leader>C :Commits<CR>

" ---------------------------
" rainbow_parentheses.vim
" ---------------------------
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

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
" Other
" ---------------------------
let g:EnErrorStyle='SpellBad'
"
" vim-clojure-conceal
let g:clojure_conceal_extras=1   " fn, defn-, letfn, and #() to unicode symbols

" Airline
let g:airline_powerline_fonts = 1
set laststatus=2

" Markdown
au BufRead,BufNewFile *.md set filetype=markdown
let g:markdown_fenced_languages = ['clojure', 'html', 'javascript', 'ruby', 'scala', 'vim']

" ===========================
" Spellcheck
" ===========================
set spelllang=en
set spellfile=$HOME/.vim/spell/en.utf-8.add " spellcheck dictionary location
set complete+=kspell                        " word comletion via ctrl n/p
autocmd FileType gitcommit setlocal spell   " spellcheck git commit messages
autocmd FileType markdown  setlocal spell   " spelllcheck markdown files

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

