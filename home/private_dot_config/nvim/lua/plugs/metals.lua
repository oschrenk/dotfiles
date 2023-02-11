return {
  "scalameta/nvim-metals",
  dependencies = {
    'hrsh7th/cmp-nvim-lsp'
  },
  ft = {'scala', 'sbt' },
  config = function()

    local metals_config = require("metals").bare_config()

    metals_config.settings = {
      showImplicitArguments = true,
      excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
    }
    metals_config.init_options.statusBarProvider = "on"

    metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

    vim.cmd([[autocmd FileType scala,sbt lua require("metals").initialize_or_attach({})]])

    local function map(mode, lhs, rhs)
      local options = { noremap = true }
      vim.api.nvim_set_keymap(mode, lhs, rhs, options)
    end

    map("n", "gD", "<cmd>lua vim.lsp.buf.definition()<CR>")
    map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
    map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
    map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
    map("n", "gds", "<cmd>lua vim.lsp.buf.document_symbol()<CR>")
    map("n", "gws", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>")
    map("n", "<leader>sh", [[<cmd>lua vim.lsp.buf.signature_help()<CR>]])
    map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
    map("n", "<leader>f", "<cmd>lua vim.lsp.buf.format{async = true }<CR>")

  end
}
