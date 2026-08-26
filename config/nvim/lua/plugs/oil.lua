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
      ["<Esc>"] = "actions.close",
      ["<C-l>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["gs"] = "actions.change_sort",
      ["gx"] = "actions.open_external",
      ["g."] = "actions.toggle_hidden",
      ["yp"] = {
        desc = "Copy path relative to project root",
        callback = function()
          local oil = require("oil")
          local entry = oil.get_cursor_entry()
          local dir = oil.get_current_dir()
          if not entry or not dir then
            return
          end

          -- find root
          local root = vim.fs.root(dir, { ".git", "go.mod", "README.md" })
          if not root then
            root = vim.fn.getcwd() -- fallback to cwd
          end

          -- relativize
          local relpath = dir:gsub("^" .. vim.pesc(root) .. "/?", "")
          if relpath ~= "" and not relpath:match("/$") then
            relpath = relpath .. "/"
          end

          local fullpath = relpath .. entry.name
          vim.fn.setreg("+", fullpath)
          vim.notify("Copied: " .. fullpath, vim.log.levels.INFO)
        end,
      },
      ["yP"] = {
        desc = "Copy absolute path to clipboard",
        callback = function()
          require("oil.actions").copy_entry_path.callback()
          vim.fn.setreg("+", vim.fn.getreg(vim.v.register))
        end,
      },
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
