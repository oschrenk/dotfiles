-- typescript
-- https://github.com/typescript-language-server/typescript-language-server
-- brew install typescript-language-server
return {
  cmd = { "typescript-language-server", "--stdio" },
  root_markers = { "tsconfig.json" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },

  telemetry = { enabled = false },
  capabilities = require("blink.cmp").get_lsp_capabilities(),

  settings = {
    completions = {
      completeFunctionCalls = true,
    },
  },
}
