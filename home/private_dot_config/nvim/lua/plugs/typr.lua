-- https://github.com/nvzone/typr
-- typing practice plugin with dashboard
return {
  "nvzone/typr",
  cmd = { "Typr", "TyprStats" },
  keys = {
    {
      "<leader>Ty",
      ":Typr<CR>",
      mode = { "n" },
      desc = "Typr: Start",
    },
    {
      "<leader>Ts",
      ":TyprStats<CR>",
      mode = { "n" },
      desc = "Typr: Stats",
    },
  },
  dependencies = "nvzone/volt",
  opts = {
    insert_on_start = true,
    stats_filepath = vim.env.XDG_DATA_HOME .. "/typr/stats",
  },
}
