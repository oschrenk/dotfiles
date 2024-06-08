-- https://github.com/rgroli/other.nvim
-- Open alternative files for the current buffer
return {
  "rgroli/other.nvim",
  cmd = { "Other" },
  config = function()
    require("other-nvim").setup({
      mappings = {
        -- builtin mappings
        "golang",
        -- custom mapping
      },
      showMissingFiles = false,
      rememberBuffers = false,
    })
  end,
}
