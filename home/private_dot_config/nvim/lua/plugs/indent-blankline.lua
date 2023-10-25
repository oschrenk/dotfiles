return {
  "lukas-reineke/indent-blankline.nvim",
  event = { "BufNewFile", "BufRead", "BufAdd" },
  main = "ibl",
  config = function()
    require("ibl").setup({
      indent = {
        char = { "|", "¦", "┆", "┊", "│", "│", "│", "│", "│", "│" },
      },
      exclude = {
        filetypes = {
          "list",
        },
        buftypes = {
          "help",
          "loclist",
          "nofile",
          "prompt",
          "quickfix",
          "telescope",
          "terminal",
        },
      },
    })
  end,
}
