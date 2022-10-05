local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  -- startup
  use 'mong8se/actually.nvim' -- ask for file to open if ambigous

  -- tmux
  use 'christoomey/vim-tmux-navigator' -- navigate over tmux panes and vim splits

  -- finding
  use 'nvim-telescope/telescope.nvim'
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  -- navigation
  use 'lambdalisue/fern.vim'
  use 'lambdalisue/nerdfont.vim'
  use 'lambdalisue/fern-renderer-nerdfont.vim'
  use 'lambdalisue/fern-git-status.vim'

  use 'airblade/vim-rooter' -- auto sets working directory

  -- completion
  use 'hrsh7th/nvim-cmp'          -- completion engine
  use 'hrsh7th/cmp-buffer'        -- complete from buffer
  use 'andersevenrud/cmp-tmux'    -- complete from tmux panes
  use 'meetcw/cmp-browser-source' -- complete from browser
  use 'hrsh7th/cmp-nvim-lsp'      -- complete from lsp
  use 'hrsh7th/cmp-vsnip'         -- snippet engine
  use 'hrsh7th/vim-vsnip'         -- snippet engine

  -- control
  use 'tpope/vim-repeat'          -- enable repeating for some plugins
  use 'tpope/vim-surround'        -- quote/parenthesize the surrounded code
  use 'tpope/vim-commentary'      -- comment stuff. Use gcc on line, gc on visual block

  -- text objects
  use 'kana/vim-textobj-user'     -- create your own text-objects
  use 'mattn/vim-textobj-url'     -- au/iu for url

  -- git
  use 'nvim-lua/plenary.nvim'     -- lua dependency
  use 'lewis6991/gitsigns.nvim'   -- lua Git integration for buffers
  use 'f-person/git-blame.nvim'   -- integrate Git blame

  -- treesitter
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'p00f/nvim-ts-rainbow'      -- rainbow parentheses

  --language server
  use 'scalameta/nvim-metals'

  -- themes
  use 'ellisonleao/gruvbox.nvim'


  require('gitsigns').setup()
  -- disable git blame by default, very slow
  vim.g.gitblame_enabled = 0

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
