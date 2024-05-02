-- https://github.com/chrisgrieser/nvim-spider
--
-- enhances built in w, e, b motions with two features:
--
-- 1. Subword Motion
--    movements happen by subwords, meaning it stops at the sub-parts of a
--    camelCase, SCREAMING_SNAKE_CASE, or kebab-case variable.
--
-- 2. Skipping Insignificant Punctuation
--    one or more punctuation characters is considered significant if it is
--    surrounded by whitespace and does not include any non-punctuation characters.
return {
  "chrisgrieser/nvim-spider",
  event = "VeryLazy",
  opts = true,
  keys = {
    {
      "w",
      function()
        require("spider").motion("w")
      end,
      mode = { "n", "x" },
      desc = "Spider-w",
    },
    {
      "e",
      function()
        require("spider").motion("e")
      end,
      mode = { "n", "x" },
      desc = "Spider-e",
    },
    {
      "b",
      function()
        require("spider").motion("b")
      end,
      mode = { "n", "x" },
      desc = "Spider-b",
    },
    {
      "ge",
      function()
        require("spider").motion("ge")
      end,
      mode = { "n", "x" },
      desc = "Spider-ge",
    },
  },
}
