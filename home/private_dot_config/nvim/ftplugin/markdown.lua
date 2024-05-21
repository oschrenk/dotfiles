vim.opt.spell = true

local path = vim.api.nvim_buf_get_name(0)

-- very dumb test to see if we are in obsidian vault
if string.find(path, "obsidian") then
  vim.opt_local.conceallevel = 2
else
  vim.opt_local.conceallevel = 0
end
