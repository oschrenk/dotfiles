-- https://github.com/chrisgrieser/nvim-various-textobjs
-- bundle of text objects
return {

  "chrisgrieser/nvim-various-textobjs",
  lazy = false,
  opts = {
    keymaps = {
      useDefaults = true,
    },
  },
  config = function()
    vim.keymap.set({ "o", "x" }, "is", '<cmd>lua require("various-textobjs").subword("inner")<CR>')
    vim.keymap.set({ "o", "x" }, "as", '<cmd>lua require("various-textobjs").subword("outer")<CR>')
    vim.keymap.set({ "o", "x" }, "iu", "<cmd>lua require('various-textobjs').url()<CR>")
    vim.keymap.set({ "o", "x" }, "im", "<cmd>lua require('various-textobjs').chainMember('inner')<CR>")
    vim.keymap.set({ "o", "x" }, "am", "<cmd>lua require('various-textobjs').chainMember('outer')<CR>")
  end,
}
