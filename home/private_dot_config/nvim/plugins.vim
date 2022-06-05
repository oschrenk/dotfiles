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

" Finding
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

" Navigation
Plug 'lambdalisue/fern.vim'
Plug 'lambdalisue/nerdfont.vim'
Plug 'lambdalisue/fern-renderer-nerdfont.vim'
Plug 'lambdalisue/fern-git-status.vim'

Plug 'airblade/vim-rooter'                                      " auto sets working directory

" Completion
Plug 'hrsh7th/nvim-cmp'          " completion engine
Plug 'hrsh7th/cmp-buffer'        " complete from buffer
Plug 'hrsh7th/cmp-path'          " complete file system path
Plug 'andersevenrud/cmp-tmux'    " complete from tmux panes
Plug 'meetcw/cmp-browser-source' " complete from browser


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
Plug 'f-person/git-blame.nvim'            " integrate Git blame

" Look and feel
Plug 'kien/rainbow_parentheses.vim'       " colored parentheses
Plug 'kshenoy/vim-signature'              " toggle, display, navigate marks

" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Themes
Plug 'ellisonleao/gruvbox.nvim'

call plug#end()

lua <<EOF
require('gitsigns').setup()
EOF

"End Plug --------------------
