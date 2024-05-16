-- https://github.com/matze/vim-move
-- move lines and selections up and down
return {
  "matze/vim-move",
  keys = {
    { "<S-Down>", "<Plug>MoveLineDown", desc = "Move line down" },

    { "<S-Down>", "<Plug>MoveBlockDown", mode = "v", desc = "Move block down" },
    { "<S-Up>", "<Plug>MoveLineUp", desc = "Move line up" },
    { "<S-Up>", "<Plug>MoveBlockUp", mode = "v", desc = "Move block up" },
  },
  init = function()
    vim.api.nvim_set_var("move_map_keys", 0)
  end,
}
