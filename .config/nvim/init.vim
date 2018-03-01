set shell=fish
set encoding=utf8         " how vim represents characters internally
set termencoding=utf-8    " used to display

" gui colors if running iTerm
if $TERM_PROGRAM =~ "iTerm"
  set termguicolors
endif

" Automatic plug installation:
if empty(glob('~/.config/nvim/autoload/plug.vim'))
		silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
		\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
		autocmd VimEnter * PlugInstall
endif

" vim-plug
call plug#begin('~/.config/nvim/plugged')

" Startup
Plug 'EinfachToll/DidYouMean'             "  asks for the right file to open if ambigous

" Externals
Plug 'rizzatti/dash.vim'                  " Dash

" tmux
Plug 'christoomey/vim-tmux-navigator'     " Navigate over tmux panes and vim splits
Plug 'tmux-plugins/vim-tmux-focus-events' " restore autocommand events within tmux eg. gitgutter refreshs

" Navigation
Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
Plug 'oschrenk/vim-vinegar'               " netrw enhancements
Plug 'airblade/vim-rooter'                " auto sets working directory

" Completion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'wellle/tmux-complete.vim'           " autocompletion from adjecent tmux panes
Plug 'thalesmello/webcomplete.vim', { 'commit': '410e178f' } " autocompletion from Chrome's current tab

" Control
Plug 'tpope/vim-repeat'                   " enable repeating for some plugins eg. vim-gitgutter
Plug 'tpope/vim-surround'                 " quote/parenthesize the surrounded code
Plug 'tpope/vim-commentary'               " Comment stuff. Use gcc on line, gc on visual block
Plug 'vim-scripts/paredit.vim'            " maintain the balanced state of matched parentheses
Plug 'tpope/vim-abolish'                  " search for, substitute, and abbreviate multiple variants of a word, adds: crs (coerce to snake_case). MixedCase (crm), camelCase (crc), snake_case (crs), and UPPER_CASE (cru)
Plug 'junegunn/vim-easy-align'            " align structures identified by a single character such as <Space>, =, :, ., |, &, #, and ,
Plug 'editorconfig/editorconfig-vim'      " Applies http://editorconfig.org config

" Motions
Plug 'terryma/vim-expand-region'          " expand/shrink selection

" Text objects
Plug 'kana/vim-textobj-user'              " create your own text-objects
Plug 'sgur/vim-textobj-parameter'         " i,/a, for function parameter
Plug 'Julian/vim-textobj-variable-segment' " iv/av change variable segments
Plug 'mattn/vim-textobj-url'              " au/iu for url
Plug 'rhysd/vim-textobj-anyblock'         " ib/ab for Quotes, Parenthesis and braces

" Git
Plug 'tpope/vim-fugitive'                 " git client in vim
Plug 'airblade/vim-gitgutter'             " mark modified, changed, deleted lines

" Ensime
Plug 'ensime/ensime-vim', { 'do': ':UpdateRemotePlugins' }

" File types
Plug 'dag/vim-fish',                      { 'for': 'fish' }
Plug 'derekwyatt/vim-sbt',                { 'for': 'sbt.scala' }           " sbt syntax
Plug 'derekwyatt/vim-scala',              { 'for': ['scala', 'markdown'] } " scala syntax
Plug 'mpollmeier/vim-scalaConceal',       { 'for': 'scala' }               " scala
Plug 'guns/vim-clojure-static',           { 'for': 'clojure' }
Plug 'fwolanski/vim-clojure-conceal',     { 'for': 'clojure' }
Plug 'rodjek/vim-puppet',                 { 'for': 'puppet' }
Plug 'vim-ruby/vim-ruby',                 { 'for': 'ruby' }
Plug 'tpope/vim-endwise',                 { 'for': 'ruby' }     " end things automatically, like end after `if, do, def` in Ruby
Plug 'dag/vim2hs',                        { 'for': 'haskell' }
Plug 'Tyilo/applescript.vim',             { 'for': 'applescript' }
Plug 'tmux-plugins/vim-tmux',             { 'for': 'tmux' }    " for .tmux.conf
Plug 'ekalinin/Dockerfile.vim'
Plug 'leafgarland/typescript-vim',        { 'for': 'typescript' }
Plug 'oschrenk/vim-journal',              { 'for': ['markdown', 'tasks']}
Plug 'alunny/pegjs-vim'

" Look and feel
Plug 'kien/rainbow_parentheses.vim'       " colored parentheses
Plug 'nathanaelkane/vim-indent-guides'    " display indent levels
Plug 'junegunn/goyo.vim', {'on': 'Goyo'}  " distraction free editing

" Themes
Plug 'morhetz/gruvbox'

call plug#end()
"End Plug --------------------

" ============================
" Look and Feel
" ============================

" hide statusbar
set laststatus=0
set background=dark
colorscheme gruvbox

" ============================
" Keyboard mappings
" ============================

" map leader to <space>
let mapleader = "\<Space>"

" escape with jk
inoremap jk <Esc>

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
syntax enable                 " syntax highlighting

set title                     " show title in console title bar.
set cursorline                " highlights line
set cursorcolumn              " highlights column
set number                    " show line number

set splitright                " always split to the right
set splitbelow                " always split to the bottom

set lsp=0                     " space it out a little more (easier to read)
set cmdheight=1               " the command bar is 2 high.
set autoindent                " copy indentation from last line
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
  if isdirectory($HOME . '/.config/nvim/undo') == 0
    :silent !mkdir -p ~/.config/nvim/undo > /dev/null 2>&1
  endif
  " if path ends in two slashes, file name will use complete path
  " :help dir
  set undodir=~/.config/nvim/undo//
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
" o automatically insert comment leader after o or O in NORMAL
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

" when writing mail from mutt, start in insert mode
au FileType mail startinsert

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
" tmux-complete
" ---------------------------
" rely on deoplete for invocations
let g:tmuxcomplete#trigger = ''

" ---------------------------
" deoplete
" ---------------------------

let g:deoplete#enable_at_startup = 1

" Let <Tab> also do completion
inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<C-i>"

if !exists('g:deoplete#omni#input_patterns')
  let g:deoplete#omni#input_patterns = {}
endif
let g:deoplete#omni#input_patterns.scala = [
  \ '[^. *\t]\.\w*', '[:\[,] ?\w*', '^import .*'
  \]

" ---------------------------
" vim-tasks
" ---------------------------
" behave closer to FoldingText.app
let g:TasksProjectMarker = '.todo'
" don't add project tag
let g:TasksTagProject    = 0

" ---------------------------
" vim-indent-guides
" ---------------------------

" Indent lines at l 2
let g:indent_guides_start_level = 2
"
" ---------------------------
" fzf
" ---------------------------
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

nnoremap <silent> <leader>/ :execute 'Rg ' . input('Rg/')<CR>
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
" goyo.vim
" ---------------------------
let g:goyo_width=70
let g:goyo_height='100%'

function! s:goyo_enter()
  " Quit Vim if this is the only remaining buffer
  let b:quitting = 0
  let b:quitting_bang = 0
  autocmd QuitPre <buffer> let b:quitting = 1
  cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!

  " dont split words on linebreak
  set linebreak
endfunction

function! s:goyo_leave()
  " Quit Vim if this is the only remaining buffer
  if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
    if b:quitting_bang
      qa!
    else
      qa
    endif
  endif
endfunction

autocmd! User GoyoEnter call <SID>goyo_enter()
autocmd! User GoyoLeave call <SID>goyo_leave()

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

" ---------------------------
" vim-clojure-conceal
" ---------------------------
let g:clojure_conceal_extras=1   " fn, defn-, letfn, and #() to unicode symbols

" ---------------------------
" markdown
" ---------------------------
au BufRead,BufNewFile *.md set filetype=markdown.tasks
let g:vim_markdown_fenced_languages = ['clojure', 'html', 'javascript', 'ruby', 'scala', 'vim']
let g:vim_markdown_folding_disabled = 1

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
iab xtime <c-r>=strftime("%H:%M")<cr>
iab xnow <c-r>=strftime("%Y%m%d %H:%M")<cr>

iab soem some
iab teh the
iab tommorow tomorrow
iab tommorrow tomorrow

