return {
  "linrongbin16/gitlinker.nvim",
  keys = {
    {
      "<leader>gc",
      function()
        return require("gitlinker").link({ action = require("gitlinker.actions").clipboard })
      end,
      desc = "Copy Git URL",
    },
    {
      "<leader>go",
      function()
        return require("gitlinker").link({ action = require("gitlinker.actions").system })
      end,
      desc = "Open Git URL",
    },
  },
}
