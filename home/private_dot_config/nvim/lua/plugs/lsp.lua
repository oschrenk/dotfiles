-- Setup
--
-- It's important that you set up the plugins in the following order:
-- 1. mason.nvim
-- 2. mason-lspconfig.nvim
-- 3. Setup servers via lspconfig

local ensure_installed = {
  "dockerfile-language-server",
  "docker-compose-language-service",
  "gopls",
  "jq-lsp",
  "lua-language-server",
  "marksman",
  "typst-lsp",
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
      "MasonUpdateAll",
    },
    event = "User FileOpened",
    lazy = true,
    config = function(_, opts)
      -- custom cmd to install/update all mason ensure_installed
      vim.api.nvim_create_user_command("MasonUpdateAll", function()
        if ensure_installed and #ensure_installed > 0 then
          vim.cmd("MasonInstall " .. table.concat(ensure_installed, " "))
        end
      end, {})

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
    lazy = true,
    event = "User FileOpened",
    dependencies = "mason.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = ensure_installed,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    dependencies = { "mason-lspconfig.nvim" },
  },
}
