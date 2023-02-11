return {
  "matze/vim-move",
  keys = {
    { "<S-Left>", "<Plug>MoveCharLeft" },
    { "<S-Down>", "<Plug>MoveLineDown" },
    { "<S-Up>", "<Plug>MoveLineUp" },
    { "<S-Right>", "<Plug>MoveCharRight" },
    { "<S-Left>", "<Plug>MoveBlockLeft", mode = "v" },
    { "<S-Down>", "<Plug>MoveBlockDown", mode = "v" },
    { "<S-Up>", "<Plug>MoveBlockUp", mode = "v" },
    { "<S-Right>", "<Plug>MoveBlockRight", mode = "v" },
  },
  init = function()
    vim.api.nvim_set_var("move_map_keys", 0)
  end,
}
