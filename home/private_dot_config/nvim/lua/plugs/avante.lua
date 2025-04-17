-- AI-driven code suggestions
-- https://github.com/yetone/avante.nvim
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
    -- https://github.com/ravitemer/mcphub.nvim
    "ravitemer/mcphub.nvim",
    {
      -- https://github.com/MeanderingProgrammer/render-markdown.nvim
      -- improve rendering Markdown files
      -- see setup in markdown.nvim
      "MeanderingProgrammer/render-markdown.nvim",
    },
  },
  opts = {
    debug = false,
    -- ----------------------
    -- PROMPT config
    -- ----------------------
    -- The system_prompt type supports both a string and a function that returns a string. Using a function here allows dynamically updating the prompt with mcphub
    system_prompt = function()
      local hub = require("mcphub").get_hub_instance()
      return hub:get_active_servers_prompt()
    end,
    -- The custom_tools type supports both a list and a function that returns a list. Using a function here prevents requiring mcphub before it's loaded
    custom_tools = function()
      return {
        require("mcphub.extensions.avante").mcp_tool(),
      }
    end,
    -- disabling built-in tooling in favor of MCPHub
    disabled_tools = {
      "list_files",
      "search_files",
      "read_file",
      "create_file",
      "rename_file",
      "delete_file",
      "create_dir",
      "rename_dir",
      "delete_dir",
      "bash",
    },
    -- ----------------------
    -- APPEARANCE config
    -- ----------------------
    windows = {
      -- % on available width, default 30
      width = 40,
      sidebar_header = {
        -- show headers in sidebar, default true
        enabled = true,
      },
      ask = {
        -- toogle floating windwow for "Ask", default false
        floating = false,
      },
      input = {
        -- prefix char in sidebar, unclear yet if used in prompt
        prefix = "> ",
        -- Height of input window in vertical layout
        height = 8,
      },
    },
    -- ----------------------
    -- BEHAVIOUR config
    -- ----------------------
    behaviour = {
      -- automatically adds keymaps, default true
      -- setting to false, will still add a subset of keymaps
      -- especially `files`
      auto_set_keymaps = true,
      -- count and show input tokens in sidear, default true.
      enable_token_counting = true,
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
      api_key_name = {
        "security",
        "find-generic-password",
        "-s",
        "avante-claude-api",
        "-a",
        "ANTHROPIC_API_KEY",
        "-w",
      },
    },
    ollama = {
      model = "gemma3:1b",
    },
    openai = {
      model = "o3-mini",
    },
  },
}
