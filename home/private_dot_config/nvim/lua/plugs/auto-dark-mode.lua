-- https://github.com/f-person/auto-dark-mode.nvim
-- automatically change appearance based on system settings
return {
  "f-person/auto-dark-mode.nvim",
  enabled = true,
  lazy = false,
  opts = {
    update_interval = 5000,
    set_dark_mode = function()
      vim.api.nvim_set_option_value("background", "dark", {})
      require("gruvbox").setup({
        overrides = {
          SignColumn = { bg = "#282828" },
          FoldColumn = { bg = "#282828" },
        },
      })
      vim.cmd("colorscheme gruvbox")
    end,
    set_light_mode = function()
      vim.api.nvim_set_option_value("background", "light", {})
      require("gruvbox").setup({
        overrides = {
          SignColumn = { bg = "#f9f1cb" },
          FoldColumn = { bg = "#f9f1cb" },
        },
      })
      vim.cmd("colorscheme gruvbox")
    end,
  },
}
