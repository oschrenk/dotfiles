-- https://github.com/stevearc/oil.nvim
-- edit filesystem like a buffer
return {
  "stevearc/oil.nvim",
  dependencies = {
    -- https://github.com/nvim-tree/nvim-web-devicons
    -- use icons from nerd fonts
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    -- disable default keymaps
    use_default_keymaps = false,
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",
      ["<C-l>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["gs"] = "actions.change_sort",
      ["gx"] = "actions.open_external",
      ["g."] = "actions.toggle_hidden",
    },
    -- Skip the confirmation popup for simple operations
    -- simple means:
    --  - no deletes
    --  - at most one copy or move
    --  - at most five creates
    -- see also :help oil.skip_confirm_for_simple_edits
    skip_confirm_for_simple_edits = true,
    view_options = {
      show_hidden = false,
    },
  },
  init = function()
    vim.keymap.set("n", "-", require("oil").open, { desc = "Open parent directory" })
  end,
}
