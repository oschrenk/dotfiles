vim.opt.spell = true

-- Relies on user having set
--   git config --local commit.style ticket
local commitStyle = vim.fn.system({ "git", "config", "--local", "commit.style", "2>/dev/null" })

-- commit.style ticket
--   print ticket number at beginning
if commitStyle == "ticket" then
  local firstLine = vim.api.nvim_get_current_line()
  if firstLine == "" then
    local branch = vim.fn.system({ "git", "branch", "--show-current", "2>/dev/null" })

    -- pick the last mentioned ticket number
    local ticket = nil
    for match in string.gmatch(branch, "[A-Z]+-[0-9]+") do
      ticket = match
    end

    if ticket then
      local pos = vim.api.nvim_win_get_cursor(0)[2]
      local newLine = firstLine:sub(0, pos) .. ticket .. ":  " .. firstLine:sub(pos + 1)
      vim.api.nvim_set_current_line(newLine)
    end
  end
end

-- always jump to the end of the line and start in insertmode
vim.cmd.normal("$")
vim.cmd("startinsert")
