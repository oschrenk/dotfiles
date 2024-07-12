-- https://github.com/norcalli/nvim-colorizer.lua
-- Colorize hex colors
return {
  "norcalli/nvim-colorizer.lua",
  cmd = { "ColorizerToggle" },
  config = function()
    require("colorizer").setup()
  end,
}
