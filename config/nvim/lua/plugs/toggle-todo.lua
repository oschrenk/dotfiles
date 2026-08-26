-- https://github.com/oschrenk/nvim-md-todo-toggle
-- Toggle todo
return {
  "oschrenk/nvim-md-todo-toggle",
  keys = {
    {
      "<C-r>",
      function()
        require("nvim-md-todo-toggle").toggle()
      end,
      desc = "Toggle todo",
    },
    {
      "<C-e>",
      function()
        require("nvim-md-todo-toggle").add()
      end,
      desc = "Add todo",
    },
  },
  config = function()
    require("nvim-md-todo-toggle").setup({
      marker = { " ", "x", "-" },
    })
  end,
}
