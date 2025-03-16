-- https://github.com/nvzone/typr
-- typing practice plugin with dashboard
return {
  "nvzone/typr",
  cmd = { "Typr", "TyprStats" },
  keys = {
    { mode = "n", "<leader>Ty", ":Typr<CR>" },
    { mode = "n", "<leader>Ts", ":TyprStats<CR>" },
  },
  dependencies = "nvzone/volt",
  opts = {
    insert_on_start = true,
    stats_filepath = vim.env.XDG_DATA_HOME .. "/typr/stats",
  },
}
