-- https://github.com/ywpkwon/yank-path.nvim
return {
  "ywpkwon/yank-path.nvim",
  cmd = {
    "YankPath",
    "YankPathBase",
    "YankPathCwd",
    "YankPathExtension",
    "YankPathFilename",
    "YankPathFull",
    "YankPathHome",
    "YankPathUri",
  },
  keys = {
    {
      "<leader>yp",
      "<cmd>YankPathCwd<CR>",
      mode = { "n" },
      desc = "Yank relative path",
    },
  },
  config = function()
    require("yank-path").setup({
      prompt = "Yank which path?",
      default_mapping = true,
      use_oil = true, -- enable built-in Oil.nvim integration
    })
  end,
}
