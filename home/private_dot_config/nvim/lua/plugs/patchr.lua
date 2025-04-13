-- https://github.com/nhu/patchr.nvim
-- apply git patches to plugins loaded via lazy.nvim
return {
  "nhu/patchr.nvim",
  lazy = false,
  ---@type patchr.config
  opts = {
    plugins = {
      ["avante.nvim"] = {
        -- Avante overrides styles in a way I don't like
        vim.fn.expand("~/.config/nvim/patches/avante.patch"),
      },
    },
  },
}
