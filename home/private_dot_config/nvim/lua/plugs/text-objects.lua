return {
  "chrisgrieser/nvim-various-textobjs",
  lazy = false,
  config = function()
    local textobjs = require("various-textobjs")

    textobjs.setup({
      useDefaultKeymaps = false,
    })

    -- https://github.com/olimorris/tmux-pomodoro-plus

    vim.keymap.set({ "o", "x" }, "is", '<cmd>lua require("various-textobjs").subword("inner")<CR>')
    vim.keymap.set({ "o", "x" }, "as", '<cmd>lua require("various-textobjs").subword("outer")<CR>')
    vim.keymap.set({ "o", "x" }, "iu", "<cmd>lua require('various-textobjs').url()<CR>")
    vim.keymap.set({ "o", "x" }, "im", "<cmd>lua require('various-textobjs').chainMember('inner')<CR>")
    vim.keymap.set({ "o", "x" }, "am", "<cmd>lua require('various-textobjs').chainMember('outer')<CR>")
  end,
}
