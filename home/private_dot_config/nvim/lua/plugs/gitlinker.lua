-- https://github.com/linrongbin16/gitlinker.nvim
-- generate sharable file permalinks (with line ranges) or
-- open directly
return {
  "linrongbin16/gitlinker.nvim",
  dependencies = { { "nvim-lua/plenary.nvim" } },
  cmd = "GitLink",
  opts = {},
  keys = {
    { "<leader>gy", "<cmd>GitLink<cr>", mode = { "n", "v" }, desc = "Yank git link" },
    { "<leader>gY", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Open git link" },
  },
}
