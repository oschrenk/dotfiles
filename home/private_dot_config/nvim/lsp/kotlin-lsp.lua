-- kotlin
-- https://github.com/Hessesian/kotlin-lsp
return {
  cmd = { vim.fn.expand("~/.local/share/cargo/bin/kotlin-lsp") },
  filetypes = { "kotlin" },
  root_markers = { "build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts" },

  capabilities = require("blink.cmp").get_lsp_capabilities(),
}
