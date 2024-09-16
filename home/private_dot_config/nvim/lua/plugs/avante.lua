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
  build = ":AvanteBuild",
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
      -- support for image pasting
      -- https://github.com/HakonHarnes/img-clip.nvim
      "HakonHarnes/img-clip.nvim",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- https://github.com/MeanderingProgrammer/render-markdown.nvim
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
