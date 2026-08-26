-- https://github.com/EvWilson/slimux.nvim
return {
  "EvWilson/slimux.nvim",
  keys = {
    {
      "<leader>st",
      function()
        local slimux = require("slimux")

        -- Save the current register content to restore later
        local save_reg = vim.fn.getreg("z")
        local save_regtype = vim.fn.getregtype("z")

        -- Yank visual selection to register z
        vim.cmd('noautocmd normal! "zy')

        -- Get the yanked text
        local text = vim.fn.getreg("z")

        -- Restore the register
        vim.fn.setreg("z", save_reg, save_regtype)

        -- Get relative filepath
        local relative_path = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")

        -- Prepend filename and send
        local prefixed_text = string.format("in %s:\n%s", relative_path, text)
        slimux.send(prefixed_text)
      end,
      mode = "v",
      desc = "Send highlighted text with filename to claude pane",
    },
  },
  config = function()
    local slimux = require("slimux")

    -- find pane running Claude process in current window
    local function find_claude_pane()
      local window = slimux.get_tmux_window()
      local cmd = string.format("tmux list-panes -t %s -F '#{pane_index} #{pane_current_command}'", window)
      local handle = io.popen(cmd)
      if not handle then
        return string.format("%s.2", window) -- fallback to pane 2
      end

      local result = handle:read("*a")
      handle:close()

      for line in result:gmatch("[^\r\n]+") do
        local pane_index, command = line:match("^(%d+)%s+(.+)$")
        if command and command:lower():match("claude") then
          return string.format("%s.%s", window, pane_index)
        end
      end

      -- fallback to pane 2 if not found
      return string.format("%s.2", window)
    end

    slimux.setup({
      target_socket = slimux.get_tmux_socket(),
      target_pane = find_claude_pane(),
    })
  end,
}
