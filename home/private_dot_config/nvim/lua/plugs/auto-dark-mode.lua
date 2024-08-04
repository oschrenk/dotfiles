return {
  "f-person/auto-dark-mode.nvim",
  enabled = true,
  lazy = false,
  opts = {
    update_interval = 5000,
    set_dark_mode = function()
      vim.api.nvim_set_option_value("background", "dark", {})
      vim.cmd("colorscheme gruvbox")
    end,
    set_light_mode = function()
      vim.api.nvim_set_option_value("background", "light", {})
      vim.cmd("colorscheme gruvbox")
    end,
  },
}
