-- https://github.com/folke/which-key.nvim
-- show available keybindings in a popup as you type
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  keys = { "<leader>", "`" },
  cmd = "WhichKey",
  init = function()
    -- wait for mapped sequence to timeout
    -- defaults to true
    vim.o.timeout = true
    -- Time in ms to wait for a mapped sequence to complete
    -- default is 1000
    vim.o.timeoutlen = 800
  end,
  opts = {
    plugins = {
      marks = true,
      registers = false,
      spelling = {
        enabled = true,
      },
      presets = {
        operators = false,
        motions = false,
        text_objects = true,
        windows = true,
        nav = false,
        z = true,
        g = true,
      },
    },
    layout = { height = { min = 4, max = 8 } },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.add({
      { "<leader>a", icon = { icon = "" }, group = "AI" },
      { "<leader>b", icon = { icon = "" }, group = "Buffer" },
      { "<leader>f", icon = { icon = "󰦅" }, group = "Find" },
      { "<leader>g", icon = { icon = "󰘭" }, group = "Git" },
      { "<leader>h", icon = { icon = "" }, group = "Hunk" },
      { "<leader>j", icon = { icon = "" }, group = "Flash" },
      { "<leader>o", icon = { icon = "" }, group = "Obsidian" },
      { "<leader>p", icon = { icon = "" }, group = "Palette" },
      { "<leader>t", icon = { icon = "󰙨" }, group = "Test" },
      { "<leader>T", icon = { icon = "󰘳" }, group = "Typr" },
      { "[", group = "prev" },
      { "]", group = "next" },
      { "g", group = "goto" },
    })
  end,
}
