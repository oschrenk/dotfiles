-- https://github.com/lewis6991/gitsigns.nvim
-- show hunks
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufNewFile", "BufRead", "BufAdd" },
  config = function()
    require("gitsigns").setup({
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end)

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end)

        -- Actions
        map("n", "<leader>hs", gitsigns.stage_hunk)
        map("n", "<leader>hr", gitsigns.reset_hunk)

        -- Toggles
        map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
        map("n", "<leader>tw", gitsigns.toggle_word_diff)

        -- Text object
        map({ "o", "x" }, "ih", gitsigns.select_hunk)
      end,
    })
  end,
}
