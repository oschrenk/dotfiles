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
      "<leader>ac",
      desc = "Avante: Chat",
      mode = { "n", "v" },
      function()
        require("avante.api").ask({ ask = false })
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
    -- ----------------------
    -- REQUIRED
    -- ----------------------
    -- https://github.com/nvim-treesitter/nvim-treesitter
    "nvim-treesitter/nvim-treesitter",
    -- https://github.com/nvim-lua/plenary.nvim
    "nvim-lua/plenary.nvim",
    -- https://github.com/stevearc/dressing.nvim
    "stevearc/dressing.nvim",
    -- https://github.com/MunifTanjim/nui.nvim
    "MunifTanjim/nui.nvim",
    --
    -- ----------------------
    -- OPTIONAL
    -- ----------------------
    --
    -- "nvim-tree/nvim-web-devicons"
    "nvim-tree/nvim-web-devicons",
    {
      -- see markdown setup in markdown.nvim
    },
  },
  opts = {
    -- ----------------------
    -- GENERAL config
    -- ----------------------
    windows = {
      -- default 30
      width = 40,
      sidebar_header = {
        enabled = false,
      },
      behaviour = {
        enable_token_counting = false,
      },
      hints = { enabled = true },
    },
    -- ----------------------
    -- PROVIDER config
    -- ----------------------
    claude = {
      model = "claude-3-7-sonnet",
      -- register account
      -- retrieve api key
      --   https://claude.ai/settings/account
      --
      -- export ANTHROPIC_API_KEY="..."
      -- security add-generic-password -s "avante-claude-api" -a "ANTHROPIC_API_KEY" -w "$ANTHROPIC_API_KEY"
      --
      -- providing a
      --  - string => interpreted as key
      --  - table  => executed as cmd
      api_key_name = { "security", "find-generic-password", "-s", "avante-claude-api", "-a", "ANTHROPIC_API_KEY", "-w" },
    },
    gemini = {
      -- config
    },
    ollama = {
      model = "gemma3:1b",
    },
    openai = {
      model = "o3-mini",
    },
  },
}
