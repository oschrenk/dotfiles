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
  use 'lewis6991/impatient.nvim' -- optimize startuptime
  use 'dstein64/vim-startuptime' -- :StartupTime after `nvim --startuptime`
  use 'mong8se/actually.nvim'    -- ask for file to open if ambigous
  use 'airblade/vim-rooter'      -- auto sets working directory
  use {
    'ethanholz/nvim-lastplace',  -- remember last cursor position
    config = function()
      require'nvim-lastplace'.setup {
        lastplace_ignore_buftype = {"quickfix", "nofile", "help"},
        lastplace_ignore_filetype = {"gitcommit", "gitrebase", "svn", "hgcommit"},
        lastplace_open_folds = true
      }
    end
  }

  -- tmux
  use 'christoomey/vim-tmux-navigator' -- navigate over tmux panes and vim splits

  -- search
  use {
    {
      'nvim-telescope/telescope.nvim',             -- fancy fuzzy finder
      config = [[require('config.telescope_config')]],
      setup = [[require('config.telescope_setup')]],
      module = 'telescope',
      cmd = 'Telescope',
    }, {
      'nvim-telescope/telescope-fzf-native.nvim',  -- use fzf
      run = 'make'
    },
    'crispgm/telescope-heading.nvim',              -- search through markdown headings
  }

  -- explorer
  use 'lambdalisue/fern.vim'
  use 'lambdalisue/nerdfont.vim'
  use 'lambdalisue/fern-renderer-nerdfont.vim'
  use 'lambdalisue/fern-git-status.vim'

  -- motion
  use {
    'ggandor/leap.nvim',
    config = function()
      require('leap').add_default_mappings()
    end
  }
  use {
    "kylechui/nvim-surround",
    tag = '*',
    config = function()
      require("nvim-surround").setup()
    end
  }

  -- completion
  --
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      { 'andersevenrud/cmp-tmux', after = 'nvim-cmp' }, -- complete from tmux
      { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },     -- complete from buffer
      'hrsh7th/cmp-nvim-lsp',   -- complete from lsp
      { 'meetcw/cmp-browser-source', after = 'nvim-cmp' }, -- complete from browser
      { 'hrsh7th/cmp-vsnip', after = 'nvim-cmp' },      -- snippet engine
      { 'hrsh7th/vim-vsnip', after = 'nvim-cmp' },      -- snippet engine
    },
    config = [[require('config.cmp_config')]],
    event = 'InsertEnter',
  }

  -- text objects
  use 'kana/vim-textobj-user'     -- create your own text-objects
  use 'mattn/vim-textobj-url'     -- au/iu for url
  use {
    'numToStr/Comment.nvim',  -- use gcc on line, gc on visual block
    config = function()
      require('Comment').setup()
    end
  }

  -- git
  use {
    'lewis6991/gitsigns.nvim',    -- draw git decorations
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('gitsigns').setup{
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true})

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true})

          -- Actions
          map({'n', 'v'}, '<space>hs', ':Gitsigns stage_hunk<CR>')
          map({'n', 'v'}, '<space>hu', ':Gitsigns reset_hunk<CR>')

          -- Text object
          map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
        end
      }
    end
  }

  -- treesitter & highlighting
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'p00f/nvim-ts-rainbow'      -- rainbow parentheses
  use 'David-Kunz/markid'         -- rainbow identifiers

  --language server
  use {
    'scalameta/nvim-metals',
    requires = {
      'hrsh7th/cmp-nvim-lsp'
    },
    config = [[require('config.metals_config')]],
  }

  -- ui
  use 'ellisonleao/gruvbox.nvim'             -- theme
  use "lukas-reineke/indent-blankline.nvim"  -- show line

  use {
    'ja-ford/delaytrain.nvim',  -- break habits and learn navigation
    config = function()
      require('delaytrain').setup {
        delay_ms = 250,
        grace_period = 3,
        keys = {
          ['nv'] = {'h', 'l'},
          ['nvi'] = {'<Left>', '<Down>', '<Up>', '<Right>'},
        },
        ignore_filetypes = {"fern"}
      }
    end
  }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
