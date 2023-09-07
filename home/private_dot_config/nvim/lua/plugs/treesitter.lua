return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  dependencies = {
    "David-Kunz/markid",
    "HiPhish/nvim-ts-rainbow2",
    "nvim-treesitter/nvim-treesitter-textobjects"
  },
  config = function()
    require("nvim-treesitter.configs").setup({
      context_commentstring = {
        enable = true,
        enable_autocmd = false
      },
      ensure_installed = {
        "bash",
        "comment",
        "css",
        "diff",
        "fish",
        "git_config",
        "git_rebase",
        "gitcommit",
        "gitignore",
        "go",
        "hcl",
        "hocon",
        "html",
        "javascript",
        "jq",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "rst",
        "rust",
        "scala",
        "swift",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      },
      -- `textobjects` via nvim-treesitter/nvim-treesitter-context
      -- see https://github.com/nvim-treesitter/nvim-treesitter-textobjects
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@conditional.outer",
            ["ic"] = "@conditional.inner",
          },
          selection_modes = {
            ["@function.outer"] = "v",
            ["@function.inner"] = "v",
            ["@conditional.outer"] = "v",
            ["@conditional.inner"] = "v",
          },
          include_surrounding_whitespace = true,
        },
        swap = {
          enable = true,
          swap_next = { ["<Tab>"] = "@parameter.inner" },
          swap_previous = { ["<S-Tab>"] = "@parameter.inner" },
        },
        move = { enable = true },
        lsp_interop = { enable = true, peek_definition_code = { ["gD"] = "@*.*" } },
      },
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<CR>",
          scope_incremental = "<CR>",
          node_incremental = "<C-a>",
          node_decremental = "<C-x>",
        },
      },
      -- `rainbow` via "HiPhish/nvim-ts-rainbow2" dependency
      rainbow = {
        enable = true,
        -- list of languages you want to disable the plugin for
        disable = { },
        -- Which query to use for finding delimiters
        query = 'rainbow-parens',
        -- Highlight the entire buffer all at once
        strategy = require('ts-rainbow').strategy.global,
      },
      -- `markid` via "David-Kunz/markid" dependency
      markid = { enable = true }
    })
  end,
}
