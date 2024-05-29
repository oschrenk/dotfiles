return {
  "epwalsh/obsidian.nvim",
  cmd = { "ObsidianToday", "ObsidianDailies", "ObsidianQuickSwitch", "ObsidianNew", "ObsidianTags" },
  keys = {
    {
      "<leader>ot",
      mode = { "n", "x", "o" },
      function()
        local client = require("obsidian").get_client()
        local note = client:daily(0)
        client:open_note(note, { sync = true })

        -- simple hack to jump immediately to "tasks"
        vim.api.nvim_win_set_cursor(0, { 11, 0 })
        local key = vim.api.nvim_replace_termcodes("z<cr>", true, false, true)
        vim.api.nvim_feedkeys(key, "n", true)
      end,
      desc = "Today",
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
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
  --   "BufReadPre path/to/my-vault/**.md",
  --   "BufNewFile path/to/my-vault/**.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/personal",
        overrides = {
          daily_notes = {
            -- Optional, if you keep daily notes in a separate directory.
            folder = "10 Journals/Personal",
            -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
            template = "Journal/Daily.md",
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
          ["journal-start-date"] = today,
          ["journal-end-date"] = today,
          ["journal-section"] = "day",
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
      checkboxes = {
        -- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
        [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
        ["x"] = { char = "", hl_group = "ObsidianDone" },
        [">"] = { char = "", hl_group = "ObsidianRightArrow" },
        ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
      },
    },
  },
}
