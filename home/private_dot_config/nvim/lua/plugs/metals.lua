local metals_au_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })

-- https://github.com/scalameta/metals
return {
  "scalameta/nvim-metals",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
  ft = {
    "scala",
    "sbt",
  },
  config = function()
    local metals_config = require("metals").bare_config()

    metals_config.settings = {
      serverVersion = "latest.snapshot",
      -- prefer bsp over bloop
      -- see also https://github.com/scalameta/metals/discussions/4505
      defaultBspToBuildTool = true,
      -- see implicit parameters
      --   since v0.9.5, default: false
      showImplicitArguments = true,
      -- see inferred types for generic methods
      --   since v0.9.5, default: false
      showInferredType = true,
      excludedPackages = {
        "akka.actor.typed.javadsl",
        "com.github.swagger.akka.javadsl",
        "akka.stream.javadsl",
        "akka.http.javadsl",
      },
    }

    metals_config.init_options = {
      statusBarProvider = "on",
    }
    metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- Start metals on certain filetypes
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "scala",
        "sbt",
        "java",
      },
      callback = function()
        require("metals").initialize_or_attach(metals_config)
      end,
      group = metals_au_group,
    })

    local function map(mode, lhs, rhs)
      local options = { noremap = true }
      vim.api.nvim_set_keymap(mode, lhs, rhs, options)
    end

    map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
    map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
    map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
    map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
    map("n", "gds", "<cmd>lua vim.lsp.buf.document_symbol()<CR>")
    map("n", "gws", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>")
    map("n", "<leader>sh", [[<cmd>lua vim.lsp.buf.signature_help()<CR>]])
    map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
    map("n", "<leader>f", "<cmd>lua vim.lsp.buf.format{async = true }<CR>")
  end,
}
