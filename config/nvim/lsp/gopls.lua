-- go
-- https://github.com/golang/tools/blob/master/gopls/doc/vim.md
-- brew install gopls
return {
  cmd = { "gopls" },
  filetypes = { "go" },
  root_markers = { "go.mod", "go.sum" },

  capabilities = require("blink.cmp").get_lsp_capabilities(),
}
