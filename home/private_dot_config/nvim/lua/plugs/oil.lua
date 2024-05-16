-- https://github.com/stevearc/oil.nvim
-- edit filesystem like a buffer
return {
  "stevearc/oil.nvim",
  dependencies = {
    -- https://github.com/nvim-tree/nvim-web-devicons
    -- use icons from nerd fonts
    "nvim-tree/nvim-web-devicons",
  },
  opts = {},
  init = function()
    vim.keymap.set("n", "-", require("oil").open, { desc = "Open parent directory" })
  end,
}
