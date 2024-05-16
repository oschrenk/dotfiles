-- https://github.com/aserowy/tmux.nvim
-- tmux integration to move from vim pane to neighboring tmux pane
return {
  "aserowy/tmux.nvim",
  keys = {
    { "<C-h>", desc = "Tmux move left" },
    { "<C-j>", desc = "Tmux move down" },
    { "<C-k>", desc = "Tmux move up" },
    { "<C-l>", desc = "Tmux move right" },
  },
  config = function()
    require("tmux").setup({
      copy_sync = { enable = false },
      navigation = { cycle_navigation = true, enable_default_keybindings = true },
      resize = { enable_default_keybindings = true, resize_step_x = 1, resize_step_y = 1 },
    })
  end,
}
