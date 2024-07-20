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
  },
}
