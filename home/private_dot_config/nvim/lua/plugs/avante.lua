-- AI-driven code suggestions
-- https://github.com/yetone/avante.nvim
--
-- get api keys via
-- https://console.anthropic.com/settings/keys
return {
  "yetone/avante.nvim",
  build = "make",
  keys = {
    {
      "<leader>aa",
      desc = "Avante: Ask",
      mode = { "n", "v" },
      function()
        require("avante.api").ask()
      end,
    },
    {
      "<leader>ar",
      desc = "Avante: Refresh",
      function()
        require("avante.api").refresh()
      end,
    },
    {
      "<leader>ae",
      desc = "Avante: Edit",
      mode = "v",
      function()
        require("avante.api").edit()
      end,
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
  opts = {
    claude = {
      -- config
    },
    gemini = {
      -- config
    },
    openai = {
      model = "o3-mini",
    },
  },
}
