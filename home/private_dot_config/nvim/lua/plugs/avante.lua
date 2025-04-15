-- AI-driven code suggestions
-- https://github.com/yetone/avante.nvim
--
-- get api keys via
-- https://console.anthropic.com/settings/keys
return {
  "yetone/avante.nvim",
  build = "make",
  cmd = {
    "AvanteAsk",
    "AvanteChat",
    "AvanteEdit",
    "AvanteToggle",
  },
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
      "<leader>ac",
      function()
        require("avante.api").ask({ ask = false })
      end,
      desc = "avante: chat",
      mode = { "n", "v" },
    },
    {
      "<leader>ae",
      function()
        require("avante.api").edit()
      end,
      desc = "avante: edit",
      mode = { "n", "v" },
    },
    {
      "<leader>ar",
      function()
        require("avante.api").refresh()
      end,
      desc = "avante: refresh",
      mode = "v",
    },
    {
      "<leader>at",
      function()
        require("avante.api").toggle()
      end,
      desc = "avante: toggle",
      mode = "n",
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
    -- https://github.com/nvim-tree/nvim-web-devicons
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
      -- % on available width, default 30
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
