set shell=fish

" ============================
" Plugins
" ============================

source ~/.config/nvim/plugins.vim

" ============================
" Look and Feel
" ============================

set background=dark
colorscheme gruvbox
let g:gruvbox_sign_column = 'bg0'

set cursorcolumn       " highlights column
set cursorline         " highlights line
set display+=lastline  " show as much as possible from last line
set laststatus=0       " hide statusbar
set number             " show line number
set scrolloff=1        " ensure number of visible lines above/below cursor
set sidescrolloff=5    " ensure number of visible columns left/right to cursor
set signcolumn=number  " show sign in number column
set termguicolors      " emit 24-but colours
set title              " show title in console title bar.

" command bar
set cmdheight=2        " the command bar is 2 high.
set showmode           " show current-mode
set showcmd            " show partially-typed commands

" ============================
" Config, Global
" ============================
" window management
set splitright                " always split to the right
set splitbelow                " always split to the bottom

" behaviour
set wildmenu                  " visual autocomplete for command menu
set showmatch                 " show matching brackets

" performance
set updatetime=300            " bad experience for diagnostic messages when it's default 4000
set lazyredraw                " redraw only when we need to

" indentation and whitespace
set autoindent                " copy indentation from last line
set smartindent               " automatically inserts one extra level in some cases
set expandtab                 " <TAB> will insert 'softtabstop' spaces
set tabstop=2                 " width of the <TAB> character
set shiftwidth=2              " affects >>, <<, ==
set softtabstop=2
set backspace=2               " make backspace work like most other app

" searching
set hlsearch                  " Highlight search matches
set ignorecase                " Ignore case when searching
set inccommand=nosplit        " nvim 0.6+ only.live preview for substitute command
set incsearch                 " Highlight search matches as you type
set smartcase                 " Ignore case if pattern is lowercase, case-sensitive otherwise

" external files
set autoread                  " Set to auto read when a file is changed from the outside
set clipboard^=unnamed,unnamedplus " cross platform clipboard access
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

" ----------------------
" Filetypes
" ----------------------
" make .md markdown files
au BufRead,BufNewFile *.md set filetype=markdown

au FileType gitcommit :call AutoBranch()

" when commiting add [BRANCH] (if matching prefix), and enter insert mode
function! AutoBranch()
  " don't do anything when amending
  if getline(1) == ""
    let branch = trim(system('git branch --show-current 2>/dev/null'))
    let ticket_match = matchstr(branch, '\v^\u\u\u-[0-9]+')
    " only add prefix when branch name matches
    if ticket_match != ""
      call append(0, "[" . ticket_match . "] ")
      execute "norm k"
    endif
    " start in insert mode
    startinsert!
  end
endfunction

" ============================
" Plugin configuration
" ============================

source ~/.config/nvim/settings.coc.vim
source ~/.config/nvim/settings.echo-doc.vim
source ~/.config/nvim/settings.fzf.vim
source ~/.config/nvim/settings.netrw.vim
source ~/.config/nvim/settings.rainbow_parentheses.vim

" ============================
" Keyboard mappings
" ============================

" map leader to <space>
let mapleader = "\<Space>"

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

" move cursors naturally
nnoremap j gj
nnoremap k gk

" quickly move to end of line
nnoremap L $

" U: Redos since 'u' undos
nnoremap U :redo<cr>

" N: Find next occurrence backward
nnoremap N Nzzzv

" Use <C-c> to clear the highlighting of :set hlsearch.
if maparg('<C-c>', 'n') ==# ''
  nnoremap <silent> <C-c> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif


" ===========================
" Spellcheck
" ===========================
set spelllang=en
set spellfile=$HOME/.config/nvim/spell/en.utf-8.add " spellcheck dictionary location
set complete+=kspell                        " word comletion via ctrl n/p
autocmd FileType gitcommit setlocal spell   " spellcheck git commit messages
autocmd FileType markdown  setlocal spell   " spelllcheck markdown filetypes

" ===========================
" Auto corrections
" ===========================

iab xtoday <c-r>=strftime("%Y%m%d")<cr>
iab xToday <c-r>=strftime("%Y-%m-%d")<cr>
iab xtime <c-r>=strftime("%H:%M")<cr>
iab xnow <c-r>=strftime("%Y%m%d %H:%M")<cr>

iab soem some
iab teh the
iab tommorow tomorrow
iab tommorrow tomorrow

" ===========================
" Shortcut
" ===========================

" need to source manually
source ~/.config/nvim/plugged/vim-shortcut/plugin/shortcut.vim

Shortcut shortcut | Show shortcut menu and run chosen shortcut
  \ noremap <silent> <Leader><Leader> :Shortcuts<Return>

Shortcut time | insert current time
  \ nmap <Space>xt i<C-R>=strftime("%Y-%m-%d %a %I:%M %p")<CR><Esc>

" Jump back to last edited buffer
Shortcut repeat the last macro
  \ nnoremap <C-p> :e#<CR>
  \ inoremap <C-p> <esc>:e#<CR>

Shortcut repeat the last macro
  \ nnoremap , @@

Shortcut fzf | Search text
  \ nnoremap <silent> <Space>/ :execute 'Rg ' . input('Rg/')<CR>
Shortcut fzf | Search Git files
  \ noremap <Space>fo :GFiles<CR>
Shortcut fzf | Search files
  \ noremap <Space>fO :Files<CR>
Shortcut fzf | Search Tags
  \ noremap <Space>fT :Tags<CR>
Shortcut fzf | Search Old files and buffers
  \ noremap <Space>fH :History<CR>
Shortcut fzf | Search Marks
  \ noremap <Space>fm :Marks<CR>
Shortcut fzf | Search Commits for current buffer
  \ noremap <Space>fc :BCommits<CR>
Shortcut fzf | Search Commits
  \ noremap <Space>fC :Commits<CR>
Shortcut fzf | Search Lines in current buffer
  \ noremap <Space>fB :BLines<CR>

Shortcut! vaw textobj | select around word
Shortcut! viw textobj | select inside word

Shortcut! vaW textobj | select around WORD
Shortcut! viW textobj | select inside WORD

Shortcut! vas textobj | select around sentence
Shortcut! vis textobj | select inside sentence

Shortcut! vap textobj | select around paragraph
Shortcut! vip textobj | select inside paragraph

Shortcut! va[ textobj | select around [] block
Shortcut! vi[ textobj | select inside [] block

Shortcut! va] textobj | select around [] block
Shortcut! vi] textobj | select inside [] block

Shortcut! va( textobj | select around () block
Shortcut! vi( textobj | select inside () block

Shortcut! vab textobj | select around () block
Shortcut! vib textobj | select inside () block

Shortcut! va< textobj | select around <> block
Shortcut! vi< textobj | select inside <> block

Shortcut! va> textobj | select around <> block
Shortcut! vi> textobj | select inside <> block

Shortcut! vat textobj | select around XML tag
Shortcut! vit textobj | select inside XML tag

Shortcut! va{ textobj | select around {} block
Shortcut! vi{ textobj | select inside {} block

Shortcut! va} textobj | select around {} block
Shortcut! vi} textobj | select inside {} block

Shortcut! vaB textobj | select around {} block
Shortcut! viB textobj | select inside {} block

Shortcut! va" textobj | select around double quotes
Shortcut! vi" textobj | select inside double quotes

Shortcut! va' textobj | select around single quotes
Shortcut! vi' textobj | select inside single quotes

Shortcut! va` textobj | select around back quotes
Shortcut! vi` textobj | select inside back quotes

Shortcut! vau textobj | select around URL
Shortcut! viu textobj | select inside URL


Shortcut coc | Rename current word
  \ nmap <leader>rn <Plug>(coc-rename)

Shortcut coc | Format selected region
  \ xmap <leader>f  <Plug>(coc-format-selected)
  \ nmap <leader>f  <Plug>(coc-format-selected)

Shortcut coc | Do codeAction of selected region, ex: `<leader>aap` for current paragraph
  \ xmap <leader>a  <Plug>(coc-codeaction-selected)
  \ nmap <leader>a  <Plug>(coc-codeaction-selected)

Shortcut coc | Do codeAction of current line
  \ nmap <leader>ac  <Plug>(coc-codeaction)

Shortcut coc | Fix autofix problem of current line
  \ nmap <leader>qf  <Plug>(coc-fix-current)

Shortcut coc | Show all diagnostics
  \ nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
Shortcut coc | Manage extensions
  \ nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
Shortcut coc | Show commands
  \ nnoremap <silent> <space>c  :<C-u>CocList commands<cr>

Shortcut coc | Use <c-space> to trigger completion
  \ inoremap <silent><expr> <c-space> coc#refresh()

" Use `[g` and `]g` to navigate diagnostics
Shortcut coc | previous diagnostic
  \ nmap <silent> [g <Plug>(coc-diagnostic-prev)
Shortcut coc | next diagnostic
  \ nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Remap keys for gotos
Shortcut coc | goto definition
  \ nmap <silent> gd <Plug>(coc-definition)
Shortcut coc | goto type definition
  \ nmap <silent> gy <Plug>(coc-type-definition)
Shortcut coc | goto implementation
  \ nmap <silent> gi <Plug>(coc-implementation)
Shortcut coc | goto references
  \ nmap <silent> gr <Plug>(coc-references)

Shortcut coc | show documentation in preview window
  \ nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
