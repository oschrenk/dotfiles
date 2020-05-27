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
Plug 'tmux-plugins/vim-tmux-focus-events' " restore autocommand events within tmux eg. gitgutter refreshs

" Navigation
Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
Plug 'oschrenk/vim-vinegar'               " netrw enhancements
Plug 'airblade/vim-rooter'                " auto sets working directory
Plug 'ripxorip/aerojump.nvim', { 'do': ':UpdateRemotePlugins' }

" Completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'wellle/tmux-complete.vim'           " complete from tmux
Plug 'Shougo/echodoc.vim'                 " print doc in command line
" for Coc extensions go to
" ~/.config/coc/extensions/package.json
" and install via `yarn`

" Control
Plug 'tpope/vim-repeat'                   " enable repeating for some plugins eg. vim-gitgutter
Plug 'tpope/vim-surround'                 " quote/parenthesize the surrounded code
Plug 'tpope/vim-commentary'               " Comment stuff. Use gcc on line, gc on visual block
Plug 'tpope/vim-projectionist'            " project configuration
Plug 'machakann/vim-highlightedyank'      " highlight yank targets

" Text objects
Plug 'kana/vim-textobj-user'              " create your own text-objects
Plug 'mattn/vim-textobj-url'              " au/iu for url

" Git
Plug 'airblade/vim-gitgutter'             " mark modified, changed, deleted lines

" File types
Plug 'dag/vim-fish',                      { 'for': 'fish' }
Plug 'derekwyatt/vim-scala',              { 'for': ['scala', 'markdown'] } " scala syntax
Plug 'Tyilo/applescript.vim',             { 'for': 'applescript' }
Plug 'tmux-plugins/vim-tmux',             { 'for': 'tmux' }
Plug 'leafgarland/typescript-vim',        { 'for': 'typescript' }
Plug 'hashivim/vim-terraform',            { 'for': 'terraform' }
Plug 'mzlogin/vim-markdown-toc',          { 'for': 'markdown' }
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" Power
 Plug 'm1foley/vim-expresso'              " eval math with g=

" Look and feel
Plug 'kien/rainbow_parentheses.vim'       " colored parentheses
Plug 'kshenoy/vim-signature'              " toggle, display, navigate marks
Plug 'junegunn/goyo.vim', {'on': 'Goyo'}  " distraction free editing

" Themes
Plug 'morhetz/gruvbox'

call plug#end()
"End Plug --------------------
