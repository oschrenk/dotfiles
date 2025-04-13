-- https://github.com/epwalsh/obsidian.nvim
-- interact with Obsidian
return {
  "epwalsh/obsidian.nvim",
  cmd = {
    "ObsidianToday",
    "ObsidianDailies",
    "ObsidianQuickSwitch",
    "ObsidianNew",
    "ObsidianTags",
  },
  keys = {
    {
      "<leader>ot",
      mode = { "n", "x", "o" },
      function()
        local obsidian = require("obsidian")
        local client = obsidian.get_client()
        client:switch_workspace("work")

        local note = client:daily(0)
        client:open_note(note, { sync = true })

        vim.cmd("1/## Tasks/1")
        vim.cmd("noh")
        local old_option = vim.opt.scrolloff
        vim.opt.scrolloff = 0
        vim.cmd("normal! zt")
        vim.opt.scrolloff = old_option
      end,
      desc = "Today (Work)",
    },
    {
      "<leader>oT",
      mode = { "n", "x", "o" },
      function()
        local obsidian = require("obsidian")
        local client = obsidian.get_client()
        client:switch_workspace("personal")

        local note = client:daily(0)
        client:open_note(note, { sync = true })

        vim.cmd("1/## Tasks/1")
        vim.cmd("noh")
        local old_option = vim.opt.scrolloff
        vim.opt.scrolloff = 0
        vim.cmd("normal! zt")
        vim.opt.scrolloff = old_option
      end,
      desc = "Today (Personal)",
    },
    {
      "<leader>od",
      mode = { "n", "x", "o" },
      "<cmd>ObsidianDailies<CR>",
      desc = "Dailies",
    },
    {
      "<leader>os",
      mode = { "n", "x", "o" },
      "<cmd>ObsidianQuickSwitch<CR>",
      desc = "Switch",
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
    note_frontmatter_func = function(note)
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
    ui = {
      enable = false,
    },
  },
}
