-- ===========================
-- Auto corrections
-- ===========================
vim.cmd('iab xtoday <c-r>=strftime("%Y%m%d")<cr>')
vim.cmd('iab xToday <c-r>=strftime("%Y-%m-%d")<cr>')
vim.cmd('iab xtime <c-r>=strftime("%H:%M")<cr>')
vim.cmd('iab xnow <c-r>=strftime("%Y%m%d %H:%M")<cr>')

vim.cmd("iab soem some")
vim.cmd("iab teh the")
vim.cmd("iab tommorow tomorrow")
vim.cmd("iab tommorrow tomorrow")

-- ===========================
-- Auto Commands
-- ===========================
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- clear: Clear existing commands if the group already exists
local my_filetypes = augroup("MyFiletypes", { clear = true })
local my_actions = augroup("MyActions", { clear = true })

-- make .md markdown files
autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "md",
  command = "set filetype=markdown",
  group = my_filetypes,
})
-- make Jenkinsfile groovy
autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "Jenkinsfile",
  command = "set filetype=groovy",
  group = my_filetypes,
})
-- make *.sh.tmpl zsh (for chezmoi)
autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.sh.tmpl",
  command = "set filetype=zsh",
  group = my_filetypes,
})

-- reload aerospace on config change
autocmd({ "BufWritePost" }, {
  pattern = { "aerospace.toml" },
  command = "!aerospace reload-config",
  group = my_filetypes,
})

-- autosave when leaving buffer (to other tmux pane)
autocmd({ "FocusLost", "BufLeave" }, {
  pattern = { "*" },
  command = "silent! wa",
  group = my_actions,
})
