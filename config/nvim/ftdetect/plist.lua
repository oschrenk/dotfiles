vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.plist",
  callback = function()
    vim.bo.filetype = "xml"
  end,
})
