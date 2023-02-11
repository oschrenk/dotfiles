return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  dependencies = {},
  config = function()
    require("nvim-treesitter.configs").setup({
      context_commentstring = { enable = true, enable_autocmd = false },
      ensure_installed = {
        "bash", "fish",
        "html", "css",
        "comment", "regex", "vim",
        "lua",
        "python",
        "scala", "hocon",
        "markdown", "markdown_inline", "rst",
        "javascript", "json", "typescript", "tsx",
        "hcl"
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@conditional.outer",
            ["ic"] = "@conditional.inner",
            ["al"] = "@loop.outer",
            ["il"] = "@loop.inner",
          },
          selection_modes = {
            ["@function.outer"] = "v",
            ["@function.inner"] = "v",
            ["@conditional.outer"] = "v",
            ["@conditional.inner"] = "v",
            ["@loop.outer"] = "v",
            ["@loop.inner"] = "v",
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
          scope_incremental = '<CR>',
          node_incremental = "<C-a>",
          node_decremental = "<C-x>" },
      },
      rainbow = { enable = true, extended_mode = false, max_file_lines = 400 },
    })
  end
}
