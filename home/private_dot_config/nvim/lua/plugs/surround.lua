-- https://github.com/kylechui/nvim-surround
-- add/change/delete surrounding delimiter
return {
  "kylechui/nvim-surround",
  keys = {
    { "ys", desc = "Surround text with {motion}{char}" },
    { "ds", desc = "Delete sourounding delimiter {char}" },
    { "cs", desc = "Change sourounding delimiter {char}" },
    { "S", mode = "x", desc = "Surround selection with {char}" },
  },
  config = function()
    require("nvim-surround").setup()
  end,
}
