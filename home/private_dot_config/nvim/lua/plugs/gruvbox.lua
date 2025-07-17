-- https://github.com/ellisonleao/gruvbox.nvim
-- lua implementation of gruvbox
return {
  "ellisonleao/gruvbox.nvim",
  lazy = false, -- make sure to load this during startup
  priority = 1000, -- make sure to load this before all other plugins
  config = function()
    local palette = require("gruvbox").palette

    require("gruvbox").setup({
      overrides = {
        SignColumn = { bg = palette.dark0 },
        FoldColumn = { bg = palette.dark0 },
      },
    })
    vim.cmd("colorscheme gruvbox")
  end,
}
