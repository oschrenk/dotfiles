-- https://github.com/windwp/nvim-autopairs
-- Automatically create pairs of characters
return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = function()
    require("nvim-autopairs").setup({
      disable_filetype = {
        "fern",
        "lazy",
        "lspinfo",
        "TelescopePrompt",
      },
      -- if next character is a close pair and it doesn't have an open pair in same line, do not add a close pair
      enable_check_bracket_line = false,
      -- use treesitter to check for a pair
      check_ts = true,
      -- insert pairing bracket when at | via <M-e> then $
      -- (|foobar
      fast_wrap = { highlight = "Question", highlight_grey = "Dimmed" },
    })
  end,
}
