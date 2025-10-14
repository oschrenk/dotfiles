-- https://github.com/notjedi/nvim-rooter.lua
-- changes the working directory to the project root when you open a file or directory
-- by defauly a project root is defined as the directory containing .git directory
return {
  "notjedi/nvim-rooter.lua",
  lazy = false,
  config = function()
    require("nvim-rooter").setup({
      rooter_patterns = { "build.sbt", ".git" },
    })
  end,
}
