return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>l",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  -- everything in opts will be passed to setup()
  opts = {
    -- define your formatters
    formatters_by_ft = {
      fish = { "fish_indent" },
      javascript = { { "prettierd", "prettier" } },
      lua = { "stylua" },
      markdown = { "prettier" },
      python = { "black" },
      scala = { "scalafmt" },
      sh = { "shellcheck" },
      -- sub-list to run only the first available formatter
      typescript = { "prettier" },
      yaml = { "yamlfmt" },
      -- "*" filetype runs formatters on all filetypes.
      -- "_" filetype runs formatters on filetypes w/o configured formatters
      ["_"] = { "trim_whitespace" },
    },
    -- set up format-on-save
    format_on_save = { timeout_ms = 500, lsp_fallback = true },
  },
  -- customize formatters
  formatters = {},
  init = function() end,
}
