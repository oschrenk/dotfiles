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
