local home = os.getenv("HOME")
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
-- Spellcheck
-- ===========================
vim.o.spelllang = "en"
vim.o.spellfile = home .. "/.config/nvim/spell/en.utf-8.add" -- dictionary location

-- ===========================
-- Filetypes
-- ===========================
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local my_filetypes = augroup("MyFiletypes", { clear = true })

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
