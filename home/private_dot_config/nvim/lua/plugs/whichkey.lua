return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  keys = { "<leader>", "`" },
  cmd = "WhichKey",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
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
    defaults = {
      ["g"] = { name = "+goto" },
      ["z"] = { name = "+fold" },
      ["]"] = { name = "+next" },
      ["["] = { name = "+prev" },
      ["<leader>b"] = { name = " Buffer" },
      ["<leader>c"] = { name = " Chat GPT" },
      ["<leader>f"] = { name = "󰦅 Find" },
      ["<leader>g"] = { name = "󰘭 Git" },
      ["<leader>h"] = { name = "󰘭 Git" },
      ["<leader>l"] = { name = " Ollama" },
      ["<leader>o"] = { name = " Obsidian" },
      ["<leader>j"] = { name = " Flash" },
      ["<leader>p"] = { name = " Palette" },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.register(opts.defaults)
  end,
}
