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
    format_on_save = function()
      local options = {
        lsp_fallback = true,
        timeout_ms = 500,
      }
      if vim.bo.filetype == "kotlin" then
        options = {
          lsp_fallback = true,
          timeout_ms = 2000,
        }
      end
      return options
    end,
    formatters = {
      ktfmt = {
        -- --kotlinlang-style:     4-space indent
        -- --meta-style (default): 2-space block indent
        -- --google-style:         2-space indent
        --
        args = { "--kotlinlang-style", "$FILENAME" },
        stdin = false,
      },
    },
    -- define your formatters
    -- sub-list to run only the first available formatter
    -- eg { { "prettierd", "prettier" } }
    -- "*" filetype runs formatters on all filetypes.
    -- "_" filetype runs formatters on filetypes w/o configured formatters
    formatters_by_ft = {
      fish = { "fish_indent" },
      go = { "gofmt" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      -- brew install ktfmt
      kotlin = { "ktfmt", stop_after_first = true },
      lua = { "stylua" },
      python = { "black" },
      scala = { "scalafmt" },
      sh = { "shellcheck" },
      swift = { "swiftformat" },
      terraform = { "terraform_fmt" },
      -- cargo install taplo-cli
      toml = { "taplo" },
      typescript = { "prettier" },
      typst = { "typstyle" },
      yaml = { "yamlfmt" },
      ["_"] = { "trim_whitespace" },
    },
  },
  -- customize formatters
  formatters = {},
  init = function() end,
}
