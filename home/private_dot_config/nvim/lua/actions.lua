local home = os.getenv("HOME")

-- ===========================
-- Auto corrections
-- ===========================
vim.cmd('iab xtoday <c-r>=strftime("%Y%m%d")<cr>')
vim.cmd('iab xToday <c-r>=strftime("%Y-%m-%d")<cr>')
vim.cmd('iab xtime <c-r>=strftime("%H:%M")<cr>')
vim.cmd('iab xnow <c-r>=strftime("%Y%m%d %H:%M")<cr>')

vim.cmd('iab soem some')
vim.cmd('iab teh the')
vim.cmd('iab tommorow tomorrow')
vim.cmd('iab tommorrow tomorrow')

-- ===========================
-- Spellcheck
-- ===========================
vim.o.spelllang = 'en'
vim.o.spellfile = home .. '/.config/nvim/spell/en.utf-8.add' -- dictionary location

-- ===========================
-- Filetypes
-- ===========================
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local my_filetypes = augroup("MyFiletypes", { clear = true })

-- make .md markdown files
autocmd('BufRead,BufNewFile', {
	  pattern = 'md',
	  command = 'set filetype=markdown',
	  group = my_filetypes
  })
-- make Jenkinsfile groovy
autocmd('BufRead,BufNewFile', {
	pattern = 'Jenkinsfile',
	command = 'set filetype=groovy',
	group = my_filetypes
})

-- ===========================
-- Actions
-- ===========================
local my_actions = augroup("MyActions", { clear = true })
-- Reload when entering buffer or gaining focus
-- costs ~280ms startup time
-- au FocusGained,BufEnter * :silent! !
--
-- Autosave on focus lost or when exiting the buffer
autocmd('FocusLost,WinLeave', {
  pattern = '*',
  command = ':silent! w',
  group = my_actions
})

-- Auto-Delete trailing whitspace
autocmd('BufWritePre,WinLeave', {
  pattern = '*',
  command = [[:%s/\s\+$//e]] ,
  group = my_actions
})


