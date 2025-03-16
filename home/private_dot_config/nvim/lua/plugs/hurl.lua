-- https://github.com/jellydn/hurl.nvim
-- run HTTP requests directly from `.hurl` files
return {
  "jellydn/hurl.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  ft = "hurl",
  opts = {
    -- Show debugging info
    debug = false,
    -- Show notification on run
    show_notification = false,
    -- Show response in popup or split
    mode = "split",
    -- Default formatter
    formatters = {
      json = { "jq" }, -- Make sure you have install jq in your system, e.g: brew install jq
      html = {
        "prettier", -- Make sure you have install prettier in your system, e.g: npm install -g prettier
        "--parser",
        "html",
      },
    },
  },
  keys = {
    -- Run API request
    { "<localleader>A", "<cmd>HurlRunner<CR>", desc = "Run All requests" },
    { "<localleader>a", "<cmd>HurlRunnerAt<CR>", desc = "Run Api request" },
    { "<localleader>te", "<cmd>HurlRunnerToEntry<CR>", desc = "Run Api request to entry" },
    { "<localleader>tm", "<cmd>HurlToggleMode<CR>", desc = "Hurl Toggle Mode" },
    { "<localleader>tv", "<cmd>HurlVerbose<CR>", desc = "Run Api in verbose mode" },
    -- Run Hurl request in visual mode
    { "<localleader>h", ":HurlRunner<CR>", desc = "Hurl Runner", mode = "v" },
  },
}
