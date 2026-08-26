-- https://github.com/kevinhwang91/nvim-ufo
-- make folds look better
return {
  "kevinhwang91/nvim-ufo",
  event = { "BufReadPost", "BufNewFile" },
  keys = {
    {
      "zR",
      function()
        require("ufo").openAllFolds()
      end,
    },
    {
      "zM",
      function()
        require("ufo").closeAllFolds()
      end,
    },
  },
  dependencies = {
    "kevinhwang91/promise-async",
    "nvim-treesitter/nvim-treesitter",
    {
      "luukvbaal/statuscol.nvim",
      config = function()
        local builtin = require("statuscol.builtin")
        require("statuscol").setup({
          -- whether to right-align the cursor line number with 'relativenumber' set
          relculright = true,
          segments = {
            { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
            {
              sign = { name = { "Diagnostic" }, maxwidth = 2, auto = true },
              click = "v:lua.ScSa",
            },
            { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
            {
              sign = { name = { ".*" }, maxwidth = 2, colwidth = 1, auto = true, wrap = true },
              click = "v:lua.ScSa",
            },
          },
        })
      end,
    },
  },
  config = function()
    vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
    vim.o.foldcolumn = "1"
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    require("ufo").setup({
      provider_selector = function(bufnr, filetype, buftype)
        return { "treesitter", "indent" }
      end,
    })
  end,
}
