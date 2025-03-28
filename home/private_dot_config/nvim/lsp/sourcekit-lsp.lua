-- swift
-- https://github.com/apple/sourcekit-lsp
-- binary comes with swift
return {
  cmd = { "sourcekit-lsp" },
  filetypes = { "swift" },
  root_markers = { "Package.swift" },
  telemetry = { enabled = false },
  capabilities = require("blink.cmp").get_lsp_capabilities(),
}
