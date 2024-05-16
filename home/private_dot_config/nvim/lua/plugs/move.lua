-- https://github.com/matze/vim-move
-- move lines and selections up and down
return {
  "matze/vim-move",
  keys = {
    { "<S-Down>", "<Plug>MoveLineDown" },
    { "<S-Up>", "<Plug>MoveLineUp" },
    { "<S-Up>", "<Plug>MoveBlockUp", mode = "v" },
    { "<S-Down>", "<Plug>MoveBlockDown", mode = "v" },
  },
  init = function()
    vim.api.nvim_set_var("move_map_keys", 0)
  end,
}
