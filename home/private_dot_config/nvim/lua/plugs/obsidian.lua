-- https://github.com/obsidian-nvim/obsidian.nvim
-- interact with Obsidian
return {
  "obsidian-nvim/obsidian.nvim",
  cmd = {
    "Obsidian",
  },
  keys = {
    {
      "<leader>ot",
      mode = { "n", "x", "o" },
      desc = "Today (Work)",
      function()
        -- switch workspace
        require("obsidian.commands.workspace")({ args = "work" })
        -- open note
        require("obsidian.commands.today")({ args = 0 })
      end,
    },
    {
      "<leader>oT",
      mode = { "n", "x", "o" },
      function()
        -- switch workspace
        require("obsidian.commands.workspace")({ args = "personal" })
        -- open note
        require("obsidian.commands.today")({ args = 0 })
      end,
      desc = "Today (Personal)",
    },
    {
      "<leader>od",
      mode = { "n", "x", "o" },
      "<cmd>Obsidian dailies<CR>",
      desc = "Dailies",
    },
    {
      "<leader>op",
      mode = { "n", "x", "o" },
      "<cmd>:Obsidian workspace personal<CR>",
      desc = "Switch to personal workspace",
    },
    {
      "<leader>ow",
      mode = { "n", "x", "o" },
      "<cmd>:Obsidian workspace work<CR>",
      desc = "Switch to work workspace",
    },
    {
      "<leader>os",
      mode = { "n", "x", "o" },
      "<cmd>Obsidian quick_switch<CR>",
      desc = "Search",
    },
  },
  ft = "markdown",
  -- if you only want to load obsidian.nvim for markdown files actually in your vault:
  -- event = {
  --   -- for home shortcut '~' 'use vim.fn.expand'
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
  --   "BufReadPre path/to/my-vault/**.md",
  --   "BufNewFile path/to/my-vault/**.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",
  },
  opts = {
    log_level = vim.log.levels.WARN,
    legacy_commands = false,
    workspaces = {
      {
        name = "personal",
        path = "~/Obsidian/memex",
        overrides = {
          daily_notes = {
            -- Optional, if you daily notes in separate directory.
            folder = "40 Journals/Personal",
            -- Optional, if you want to use template from `templates.folder`
            template = "Journal/Personal/Daily.md",
          },
        },
      },
      {
        name = "work",
        path = "~/Obsidian/memex",
        overrides = {
          daily_notes = {
            -- Optional, if you daily notes in separate directory.
            folder = "40 Journals/Work",
            -- Optional, if you want to use template from `templates.folder`
            template = "Journal/Work/Daily.md",
          },
        },
      },
    },

    ---@return table
    frontmatter_func = function(note)
      local out = {}

      local isDaily = false
      for _, value in pairs(note.tags) do
        if value == "daily-notes" then
          isDaily = true
        end
      end

      if isDaily then
        local today = os.date("%Y-%m-%d")
        local journal = {
          journal = "personal",
          ["journal-date"] = today,
        }
        out = journal
      else
        -- note.metadata contains existing id, tags, ...local
        -- we ignore it for daily notes
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end
      end

      return out
    end,
    new_notes_location = "01 Inbox",
    templates = {
      folder = "99 Templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      -- {{key}} will be replaced by return value
      substitutions = {
        yesterday = function()
          return os.date("%Y-%m-%d", os.time() - 86400)
        end,
      },
    },
    statusline = {
      enabled = false,
    },
    footer = {
      enabled = false,
    },
    ui = {
      enable = false,
    },
  },
}
