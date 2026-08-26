-- lua
-- https://github.com/LuaLS/lua-language-server
-- brew install lua-language-server
return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc" },
  telemetry = { enabled = false },
  capabilities = require("blink.cmp").get_lsp_capabilities(),

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
}
