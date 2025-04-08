-- grammar
-- https://writewithharper.com
-- brew install harper
return {
  cmd = { "harper-ls", "--stdio" },
  root_markers = { "tsconfig.json" },
  filetypes = {
    "markdown",
    "gitcommit",
  },
  settings = {
    ["harper-ls"] = {
      linters = {
        SentenceCapitalization = false,
        SpellCheck = false,
      },
    },
  },
}
