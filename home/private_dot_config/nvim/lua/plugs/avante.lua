-- AI-driven code suggestions
-- https://github.com/yetone/avante.nvim
--
-- get api keys via
-- https://console.anthropic.com/settings/keys
return {
  "yetone/avante.nvim",
  opts = {
    -- add any opts here
  },
  build = "make",
  keys = {
    {
      "<leader>aa",
      function()
        require("avante.api").ask()
      end,
      desc = "avante: ask",
      mode = { "n", "v" },
    },
    {
      "<leader>ar",
      function()
        require("avante.api").refresh()
      end,
      desc = "avante: refresh",
    },
    {
      "<leader>ae",
      function()
        require("avante.api").edit()
      end,
      desc = "avante: edit",
      mode = "v",
    },
  },
  dependencies = {
    -- https://github.com/nvim-lua/plenary.nvim
    "nvim-lua/plenary.nvim",
    -- https://github.com/stevearc/dressing.nvim
    "stevearc/dressing.nvim",
    -- https://github.com/MunifTanjim/nui.nvim
    "MunifTanjim/nui.nvim",
    -- "nvim-tree/nvim-web-devicons"
    "nvim-tree/nvim-web-devicons", -- optional
    {
      -- see markdown setup in markdown.nvim
    },
  },
}
