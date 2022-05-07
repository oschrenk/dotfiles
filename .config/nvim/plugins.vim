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

" tmux
Plug 'christoomey/vim-tmux-navigator'     " Navigate over tmux panes and vim splits

" Navigation
Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'             " fuzzy find
Plug 'oschrenk/vim-vinegar'                                     " netrw enhancements
Plug 'airblade/vim-rooter'                                      " auto sets working directory


" Completion
Plug 'neoclide/coc.nvim', {'branch': 'release'} " autocompletion with language server protocol
Plug 'scalameta/coc-metals', {'do': 'yarn install --frozen-lockfile'} " install from main because of https://github.com/scalameta/coc-metals/issues/421
Plug 'wellle/tmux-complete.vim'                 " complete from tmux
Plug 'Shougo/echodoc.vim'                       " print doc in command line
" for Coc extensions go to
" ~/.config/coc/extensions/package.json
" and install via `yarn`

" Control
Plug 'tpope/vim-repeat'                   " enable repeating for some plugins
Plug 'tpope/vim-surround'                 " quote/parenthesize the surrounded code
Plug 'tpope/vim-commentary'               " Comment stuff. Use gcc on line, gc on visual block
Plug 'sunaku/vim-shortcut'                " discoverable & searchable shortcuts for (Neo)Vim

" Text objects
Plug 'kana/vim-textobj-user'              " create your own text-objects
Plug 'mattn/vim-textobj-url'              " au/iu for url

" Git
Plug 'nvim-lua/plenary.nvim'              " lua dependency for gitsigns
Plug 'lewis6991/gitsigns.nvim'            " # lua Git integration for buffers

" File types
Plug 'dag/vim-fish',                      { 'for': 'fish' }
Plug 'derekwyatt/vim-scala',              { 'for': ['scala', 'markdown'] } " scala syntax
Plug 'Tyilo/applescript.vim',             { 'for': 'applescript' }
Plug 'tmux-plugins/vim-tmux',             { 'for': 'tmux' }
Plug 'leafgarland/typescript-vim',        " typescript
Plug 'pangloss/vim-javascript',           " typescript
Plug 'peitalin/vim-jsx-typescript'        " tsx
Plug 'hashivim/vim-terraform',            { 'for': 'terraform' }
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'satabin/hocon-vim',                 " typelevel config files

" Look and feel
Plug 'kien/rainbow_parentheses.vim'       " colored parentheses
Plug 'kshenoy/vim-signature'              " toggle, display, navigate marks

" Themes
Plug 'morhetz/gruvbox'

call plug#end()

lua <<EOF
require('gitsigns').setup()
EOF

"End Plug --------------------
