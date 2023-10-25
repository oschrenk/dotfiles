-- https://github.com/notjedi/nvim-rooter.lua
-- changes the working directory to the project root when you open a file or directory
return {
  "notjedi/nvim-rooter.lua",
  event = "BufReadPost",
  config = function()
    require("nvim-rooter").setup()
  end,
}
