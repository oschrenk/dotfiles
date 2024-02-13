-- https://github.com/okuuva/auto-save.nvim
-- Auto Save buffers
return {
  "okuuva/auto-save.nvim",
  cmd = "ASToggle", -- optional for lazy loading on command
  event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
  opts = {
    enabled = true, -- start auto-save when plugin is loaded
    execution_message = {
      message = function() -- message to print on save
        return ("AutoSaved at " .. vim.fn.strftime("%H:%M:%S"))
      end,
      dim = 0.18, -- dim the color of `message`
      cleaning_interval = 1250, -- clean after (ms). See :h MsgArea
    },
    trigger_events = { -- See :h events
      immediate_save = { "BufLeave", "FocusLost" }, -- trigger an immediate save
      defer_save = { "InsertLeave", "TextChanged" }, -- trigger a deferred save (saves after `debounce_delay`)
      cancel_defered_save = { "InsertEnter" }, -- cancel a pending deferred save
    },
    condition = nil,
    write_all_buffers = false, -- write all buffers when the current one meets `condition`
    debounce_delay = 3000, -- saves the file at most every `debounce_delay` milliseconds
    callbacks = { -- functions to be executed at different intervals
      enabling = nil, -- ran when enabling auto-save
      disabling = nil, -- ran when disabling auto-save
      before_asserting_save = nil, -- ran before checking `condition`
      before_saving = nil, -- ran before doing the actual save
      after_saving = nil, -- ran after doing the actual save
    },
  },
}
