--- https://github.com/coder/claudecode.nvim
---@type LazySpec
return {
  "coder/claudecode.nvim",
  -- load on start (but delayed) to allow IDE integration from another tmux pane
  -- (/ide)
  event = "VeryLazy",
  -- Keybindings that control tmux directly
  keys = {
    {
      "<Leader>as",
      function()
        local file = vim.fn.expand("%:p")
        vim.cmd("ClaudeCodeAdd " .. file)
      end,
      desc = "Send current file to Claude",
    },
    {
      "<Leader>aS",
      "<cmd>ClaudeCodeSend<cr>",
      desc = "Send selection to Claude",
      mode = { "n", "v" },
    },
  },
  opts = {
    terminal = {
      -- for working with tmux only - disables internal terminal buffer
      -- no UI actions; server + tools remain available
      -- start Claude with `claude --ide`
      provider = "none",
    },
    -- Keymaps for diff review (aligned with your patterns)
    keymaps = {
      accept = "<Leader>aa", -- Accept Claude's changes
      deny = "<Leader>ad", -- Reject changes
      edit = "<Leader>ae", -- Edit before accepting
    },
    diff_opts = {
      open_in_current_tab = false, -- Open diffs in a new tab
      auto_close_on_accept = true, -- Automatically close diff after accepting
    },
  },
}
