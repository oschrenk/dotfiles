-- Setup, "markdown"
--
-- It's important that you set up the plugins in the following order:
-- 1. mason.nvim
-- 2. mason-lspconfig.nvim
-- 3. Setup servers via lspconfig

-- Resources
-- https://github.com/VonHeikemen/nvim-starter/blob/xx-mason/init.lua
-- https://github.com/bluz71/dotfiles/blob/9e90fbb99e66501b374c8441f559d649788b028f/nvim/lua/config/lsp-config.lua#L108

-- list of valid names
-- https://raw.githubusercontent.com/neovim/nvim-lspconfig/master/doc/server_configurations.md
-- :help lspconfig-all
local ensure_installed = {
  "cssls",
  "dockerls",
  "eslint",
  "gopls",
  "html",
  "lua_ls",
  "marksman",
  -- while sourcekit is available as an lspconfig,
  -- it's binary is delivered with swift and thus "outside"
  -- because of that mason doesn't manage it
  -- see also https://github.com/williamboman/mason.nvim/issues/208#issuecomment-1200488465
  -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#sourcekit
  -- "sourcekit",
  "tsserver",
}

return {
  {
    "williamboman/mason.nvim",
    cmd = {
      "Mason",
      "MasonInstall",
      "MasonLog",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonUpdate",
    },
    lazy = true,
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
        max_concurrent_installers = 2,
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    cmd = { "LspInstall", "LspUninstall" },
    event = { "BufRead" },
    lazy = true,
    dependencies = {
      "williamboman/mason.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
      local mason_lspconfig = require("mason-lspconfig")
      mason_lspconfig.setup({
        ensure_installed = ensure_installed,
        handlers = {
          function(server)
            lspconfig[server].setup({
              capabilities = lsp_capabilities,
            })
          end,
          ["lua_ls"] = function()
            lspconfig.lua_ls.setup({
              capabilities = lsp_capabilities,
              -- see https://luals.github.io/wiki/settings/
              settings = {
                Lua = {
                  diagnostics = {
                    -- ignore some globals
                    globals = {
                      -- neovim
                      "vim",
                      -- hammerspoon
                      "hs",
                    },
                  },
                  workspace = {
                    ignoreDir = {
                      "undo/**",
                    },
                  },
                },
              },
            })
          end,
          ["tsserver"] = function()
            lspconfig.tsserver.setup({
              capabilities = lsp_capabilities,
              settings = {
                completions = {
                  completeFunctionCalls = true,
                },
              },
            })
          end,
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    dependencies = { "mason-lspconfig.nvim" },
  },
}
