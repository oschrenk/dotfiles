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

-- use {
--   'myusername/example',        -- The plugin location string
--   -- The following keys are all optional
--   disable = boolean,           -- Mark a plugin as inactive
--   as = string,                 -- Specifies an alias under which to install the plugin
--   installer = function,        -- Specifies custom installer. See "custom installers" below.
--   updater = function,          -- Specifies custom updater. See "custom installers" below.
--   after = string or list,      -- Specifies plugins to load before this plugin. See "sequencing" below
--   rtp = string,                -- Specifies a subdirectory of the plugin to add to runtimepath.
--   opt = boolean,               -- Manually marks a plugin as optional.
--   bufread = boolean,           -- Manually specifying if a plugin needs BufRead after being loaded
--   branch = string,             -- Specifies a git branch to use
--   tag = string,                -- Specifies a git tag to use. Supports '*' for "latest tag"
--   commit = string,             -- Specifies a git commit to use
--   lock = boolean,              -- Skip updating this plugin in updates/syncs. Still cleans.
--   run = string, function, or table, -- Post-update/install hook. See "update/install hooks".
--   requires = string or list,   -- Specifies plugin dependencies. See "dependencies".
--   rocks = string or list,      -- Specifies Luarocks dependencies for the plugin
--   config = string or function, -- Specifies code to run after this plugin is loaded.
--   -- The setup key implies opt = true
--   setup = string or function,  -- Specifies code to run before this plugin is loaded. The code is ran even if
--                                -- the plugin is waiting for other conditions (ft, cond...) to be met.
--   -- The following keys all imply lazy-loading and imply opt = true
--   cmd = string or list,        -- Specifies commands which load this plugin. Can be an autocmd pattern.
--   ft = string or list,         -- Specifies filetypes which load this plugin.
--   keys = string or list,       -- Specifies maps which load this plugin. See "Keybindings".
--   event = string or list,      -- Specifies autocommand events which load this plugin.
--   fn = string or list          -- Specifies functions which load this plugin.
--   cond = string, function, or list of strings/functions,   -- Specifies a conditional test to load this plugin
--   module = string or list      -- Specifies Lua module names for require. When requiring a string which starts
--                                -- with one of these module names, the plugin will be loaded.
--   module_pattern = string/list -- Specifies Lua pattern of Lua module names for require. When
--                                -- requiring a string which matches one of these patterns, the plugin will be loaded.
-- }

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
    end,
    requires =  {
      'ggandor/flit.nvim',
      after = 'leap.nvim',
      config = function()
        require('flit').setup {
          keys = { f = 'f', F = 'F', t = 't', T = 'T' },
          -- A string like "nv", "nvo", "o", etc.
          labeled_modes = "nv",
          multiline = true,
          -- Like `leap`s similar argument (call-specific overrides).
          -- E.g.: opts = { equivalence_classes = {} }
          opts = {}
        }
      end
    },
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
    ft = {'scala', 'sbt' },
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
