return {
  "projekt0n/caret.nvim",
  lazy = false, -- make sure to load this during startup
  priority = 1000, -- make sure to load this before all other plugins
  config = function()
    require("caret").setup({
      -- ...
    })

    vim.cmd("colorscheme caret")
  end,
}
