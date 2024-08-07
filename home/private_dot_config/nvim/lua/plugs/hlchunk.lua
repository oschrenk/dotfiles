return {
  "shellRaining/hlchunk.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("hlchunk").setup({
      chunk = {
        enable = false,
        use_treesitter = true,
        -- initial delay of animation
        -- 0 removes
        delay = 0,
        -- duration of animation
        duration = 50,
        chars = {
          horizontal_line = "─",
          vertical_line = "│",
          left_top = "╭",
          left_bottom = "╰",
          right_arrow = "─",
        },
        style = {
          { fg = "#CB8764" },
        },
        exclude_filetypes = {},
      },
      indent = {
        enable = true,
        chars = { "│", "¦", "┆", "┊" },
        -- list of colors
        style = {
          vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui"),
        },
        ahead_lines = 20,
        delay = 100,
      },
      blank = {
        enable = false,
      },
      line_num = {
        enable = false,
        use_treesitter = true,
      },
    })
  end,
}
