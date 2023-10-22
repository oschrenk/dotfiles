return {
  "projekt0n/caret.nvim",
  config = function()
    require("caret").setup({
      -- ...
    })

    vim.cmd("colorscheme caret")
  end,
}
