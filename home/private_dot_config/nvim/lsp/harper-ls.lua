-- grammar
-- https://writewithharper.com
-- brew install harper
return {
  cmd = { "harper", "--stdio" },
  root_markers = { "tsconfig.json" },
  filetypes = {
    "markdown",
    "gitcommit",
  },
  settings = {
    linters = {
      SentenceCapitalization = false,
      SpellCheck = false,
    },
  },
}
