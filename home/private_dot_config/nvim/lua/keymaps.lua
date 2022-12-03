-- ============================
-- Keyboard mappings
-- ============================
-- noremap:
-- silent:
local opts = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap

-- Leader/local leader
vim.g.mapleader = [[ ]]
vim.g.maplocalleader = [[,]]

-- disable arrow keys
for _, mode in ipairs({'n','i', 'v'}) do
  map(mode, '<Up>', '<Nop>', opts)
  map(mode, '<Down>', '<Nop>', opts)
  map(mode, '<Left>', '<Nop>', opts)
  map(mode, '<Right>', '<Nop>', opts)
end

-- do not enter Ex mode by accident
map("n", "Q", "<Nop>", opts)


-- move cursors naturally
map('n', 'j', 'gj', opts)
map('n', 'k', 'gk', opts)

-- U: Redos since 'u' undos
map('n', 'U', ':redo<cr>', opts)

-- N: Find next occurrence backward
map('n', 'N', 'Nzzzv', opts)

-- Use <C-c> to clear the highlighting of :set hlsearch.
map('n', '<C-c>', [[:nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>]], opts)
