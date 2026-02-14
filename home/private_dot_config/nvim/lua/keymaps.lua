-- ============================
-- Keyboard mappings
-- ============================
local map = vim.keymap.set
local opts = { silent = true }

-- Leader/local leader
vim.g.mapleader = [[ ]]
vim.g.maplocalleader = [[,]]

-- disable arrow keys
for _, mode in ipairs({ "n", "i", "v" }) do
  map(mode, "<Up>", "<Nop>", opts)
  map(mode, "<Down>", "<Nop>", opts)
  map(mode, "<Left>", "<Nop>", opts)
  map(mode, "<Right>", "<Nop>", opts)
end

-- Disable scrolling
-- https://neovim.io/doc/user/scroll.html
map({ "n", "v" }, "<C-e>", "<Nop>")
-- quit on Ctrl+D
map({ "n", "v" }, "<C-d>", "<cmd>q<cr>")
map({ "n", "v" }, "<C-f>", "<Nop>")
map({ "n", "v" }, "<C-y>", "<Nop>")
map({ "n", "v" }, "<C-u>", "<Nop>")
map({ "n", "v" }, "<C-b>", "<Nop>")

-- do not enter Ex mode by accident
map("n", "Q", "<Nop>", opts)

-- move cursors naturally
map("n", "j", "gj", opts)
map("n", "k", "gk", opts)

-- don't overwrite the register
map("v", "P", "pgvy", opts)

-- U: Redos since 'u' undos
map("n", "U", ":redo<cr>", opts)

-- N: Find next occurrence backward
map("n", "N", "Nzzzv", opts)

-- Use <C-c> to clear the highlighting of :set hlsearch.
map("n", "<C-c>", [[:nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>]], opts)
