-- https://github.com/nvim-treesitter/nvim-treesitter
-- Treesitter configurations and abstraction layer
--
-- Requires: brew install tree-sitter-cli
return {
  "nvim-treesitter/nvim-treesitter",
  -- master branch is not compatible with nvim 0.12
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  dependencies = {
    -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    -- syntax aware text-objects
    { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
  },
  config = function()
    -- install parsers
    require("nvim-treesitter").install({
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
      "hurl",
      "javascript",
      "jq",
      "json",
      "kanata",
      "kdl",
      "kotlin",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "regex",
      "rst",
      "rust",
      "scala",
      "sql",
      "swift",
      "terraform",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "xml",
      "yaml",
    })

    -- textobjects
    require("nvim-treesitter-textobjects").setup({
      select = {
        lookahead = true,
        include_surrounding_whitespace = false,
      },
      move = {
        set_jumps = true,
      },
    })

    local normal_op = "n"
    local visual_op = { "x", "o" }
    local normal_visual_op = { "n", "x", "o" }

    -- swap
    local swap = require("nvim-treesitter-textobjects.swap")
    for _, mapping in ipairs({
      { "<Tab>", swap.swap_next },
      { "<S-Tab>", swap.swap_previous },
    }) do
      vim.keymap.set(normal_op, mapping[1], function()
        mapping[2]("@parameter.outer")
      end)
    end

    -- select
    local select = require("nvim-treesitter-textobjects.select")
    for _, mapping in ipairs({
      { "aa", "@parameter.outer" },
      { "ia", "@parameter.inner" },
      { "af", "@function.outer" },
      { "if", "@function.inner" },
      { "ac", "@class.outer" },
      { "ic", "@class.inner" },
      { "ii", "@conditional.inner" },
      { "ai", "@conditional.outer" },
      { "il", "@loop.inner" },
      { "al", "@loop.outer" },
      { "at", "@comment.outer" },
    }) do
      vim.keymap.set(visual_op, mapping[1], function()
        select.select_textobject(mapping[2], "textobjects")
      end)
    end

    -- move
    local move = require("nvim-treesitter-textobjects.move")
    for _, mapping in ipairs({
      { "]f", move.goto_next_start, "@function.outer" },
      { "]c", move.goto_next_start, "@class.outer" },
      { "]F", move.goto_next_end, "@function.outer" },
      { "]C", move.goto_next_end, "@class.outer" },
      { "[f", move.goto_previous_start, "@function.outer" },
      { "[c", move.goto_previous_start, "@class.outer" },
      { "[F", move.goto_previous_end, "@function.outer" },
      { "[C", move.goto_previous_end, "@class.outer" },
    }) do
      vim.keymap.set(normal_visual_op, mapping[1], function()
        mapping[2](mapping[3], "textobjects")
      end)
    end

    -- custom parser: kanata
    vim.api.nvim_create_autocmd("User", {
      pattern = "TSUpdate",
      callback = function()
        require("nvim-treesitter.parsers").kanata = {
          install_info = {
            url = "https://github.com/postsolar/tree-sitter-kanata",
            branch = "master",
          },
        }
      end,
    })
    vim.treesitter.language.register("kanata", { "kbd" })
  end,
}
