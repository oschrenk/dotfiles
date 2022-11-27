local map = vim.api.nvim_set_keymap

local silent = { silent = true, noremap = true }
-- Navigate buffers and repos
map('n', '<c-p>', [[<cmd>Telescope commands<cr>]], silent)
map('n', '<c-s>', [[<cmd>Telescope git_files<cr>]], silent)
map('n', '<c-d>', [[<cmd>Telescope find_files<cr>]], silent)
map('n', '<c-m>', [[<cmd>Telescope heading<cr>]], silent)
map('n', '<c-g>', [[<cmd>Telescope live_grep<cr>]], silent)

