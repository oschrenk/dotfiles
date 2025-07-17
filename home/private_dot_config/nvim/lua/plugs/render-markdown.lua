-- https://github.com/MeanderingProgrammer/render-markdown.nvim
-- improve rendering Markdown files
return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    file_types = {
      "markdown",
    },
  },
  ft = {
    "markdown",
  },
  config = function()
    require("render-markdown").setup({
      latex = { enabled = false },
      bullet = {
        icons = {
          "•",
          "◦",
          "⋄",
        },
      },
    })
  end,
}
