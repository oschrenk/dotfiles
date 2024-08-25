return {
  "akinsho/git-conflict.nvim",
  event = "BufReadPost",
  cmd = {
    "GitConflictChooseBoth",
    "GitConflictNextConflict",
    "GitConflictChooseOurs",
    "GitConflictPrevConflict",
    "GitConflictChooseTheirs",
    "GitConflictListQf",
    "GitConflictChooseNone",
    "GitConflictRefresh",
  },
  opts = {
    default_mappings = true,
    default_commands = true,
    disable_diagnostics = true,
    highlights = {
      -- see also
      -- https://github.com/ellisonleao/gruvbox.nvim/blob/7a1b23e4edf73a39642e77508ee6b9cbb8c60f9e/lua/gruvbox.lua#L364
      current = "DiffAdd",
      incoming = "DiffText",
      ancestor = "DiffChange",
    },
  },
}
