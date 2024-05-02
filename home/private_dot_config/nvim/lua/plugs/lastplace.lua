-- https://github.com/ethanholz/nvim-lastplace
-- reopen files at their last position
-- !!! unmaintained as of 2023-07-23
return {
  "ethanholz/nvim-lastplace",
  lazy = false,
  init = function() end,
  config = function()
    require("nvim-lastplace").setup({
      lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
      lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
      lastplace_open_folds = true,
    })
  end,
}
