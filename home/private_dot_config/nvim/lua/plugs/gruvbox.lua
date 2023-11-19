return {
  "ellisonleao/gruvbox.nvim",
  lazy = false, -- make sure to load this during startup
  priority = 1000, -- make sure to load this before all other plugins
  config = function()
    -- load the colorscheme here
    vim.cmd([[colorscheme gruvbox]])
    vim.g["gruvbox_sign_column"] = "bg0"
  end,
}
