-- https://github.com/numToStr/Comment.nvim
-- plugin to make commenting easier
return {
  "numToStr/Comment.nvim",
  keys = { { "gc", mode = { "n", "x" } } },
  -- sets commentstring based on location in file
  -- useful for embedded languages
  dependencies = "JoosepAlviste/nvim-ts-context-commentstring",
  config = function()
    require("Comment").setup({
      toggler = { line = "gcc", block = "<Nop>" },
      opleader = { line = "gc", block = "<Nop>" },
      -- helper for jsx/tsx files
      pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
    })
  end,
}
