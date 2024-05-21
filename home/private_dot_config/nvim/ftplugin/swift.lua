local root_dir = vim.fs.dirname(vim.fs.find({
  "Package.swift",
  ".git",
}, { upward = true })[1])
local client = vim.lsp.start({
  name = "sourcekit-lsp",
  cmd = { "sourcekit-lsp" },
  root_dir = root_dir,
})
vim.lsp.buf_attach_client(0, client)
