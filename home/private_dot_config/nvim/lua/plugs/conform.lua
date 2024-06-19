-- https://github.com/stevearc/conform.nvim
-- formatter plugin
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>bf",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  -- everything in opts will be passed to setup()
  opts = {
    -- general options
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
    -- define your formatters
    -- sub-list to run only the first available formatter
    -- eg { { "prettierd", "prettier" } }
    -- "*" filetype runs formatters on all filetypes.
    -- "_" filetype runs formatters on filetypes w/o configured formatters
    formatters_by_ft = {
      fish = { "fish_indent" },
      go = { "gofmt" },
      javascript = { { "prettierd", "prettier" } },
      lua = { "stylua" },
      python = { "black" },
      scala = { "scalafmt" },
      sh = { "shellcheck" },
      swift = { "swiftformat" },
      terraform = { "terraform_fmt" },
      typescript = { "prettier" },
      typst = { "typstfmt" },
      yaml = { "yamlfmt" },
      ["_"] = { "trim_whitespace" },
    },
  },
  -- customize formatters
  formatters = {},
  init = function() end,
}
