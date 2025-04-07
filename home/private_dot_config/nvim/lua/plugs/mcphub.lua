-- https://github.com/ravitemer/mcphub.nvim
-- manage Model Context Protocol servers
return {
  "ravitemer/mcphub.nvim",
  -- Installs required mcp-hub npm module
  -- build = "npm install -g mcp-hub@latest",
  -- if you don't want mcp-hub to be available globally or can't use -g use this and set use_bundled_binary = true in opts  (see Advanced configuration)
  build = "bundled_build.lua",
  dependencies = {
    -- Required for job and http requests
    "nvim-lua/plenary.nvim",
  },
  cmd = "MCPHub",
  config = function()
    require("mcphub").setup({
      -- Use bundled mcp-hub instead of global install
      use_bundled_binary = true,
    })
  end,
}
