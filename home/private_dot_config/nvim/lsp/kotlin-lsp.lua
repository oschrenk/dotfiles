-- kotlin
-- https://github.com/Hessesian/kmp-lsp (was kotlin-lsp; renamed upstream)
return {
  cmd = { "kmp-lsp" },
  filetypes = { "kotlin" },
  root_markers = { "build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts" },

  capabilities = require("blink.cmp").get_lsp_capabilities(),
}
