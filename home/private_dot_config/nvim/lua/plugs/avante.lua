-- AI-driven code suggestions
-- https://github.com/yetone/avante.nvim
--
-- get api keys via
-- https://console.anthropic.com/settings/keys
return {
  "yetone/avante.nvim",
  build = "make",
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
  keys = {
    {
      "<leader>aa",
      function()
        require("avante.api").ask()
      end,
      desc = "Avante: Ask",
      mode = { "n", "v" },
    },
    {
      "<leader>ar",
      function()
        require("avante.api").refresh()
      end,
      desc = "Avante: Refresh",
    },
    {
      "<leader>ae",
      function()
        require("avante.api").edit()
      end,
      desc = "Avante: Edit",
      mode = "v",
    },
  },
  opts = {
    provider = "claude",
    claude = {
      -- export ANTHROPIC_API_KEY="..."
      -- security add-generic-password -s "avante-claude-api" -a "ANTHROPIC_API_KEY" -w "$ANTHROPIC_API_KEY"
      -- if api_key_name is a table, it's treated like a command
      api_key_name = {
        "/usr/bin/security",
        "find-generic-password",
        "-s",
        "avante-claude-api",
        "-a",
        "ANTHROPIC_API_KEY",
        "-w",
      },
    },
  },
}
