return {
  "ellisonleao/gruvbox.nvim",
  lazy = false, -- make sure to load this during startup
  priority = 1000, -- make sure to load this before all other plugins
  config = function()
    require("gruvbox").setup({
      overrides = {
        SignColumn = { bg = "#282828" },
        FoldColumn = { bg = "#282828" },
      },
    })
    vim.cmd("colorscheme gruvbox")
  end,
}
