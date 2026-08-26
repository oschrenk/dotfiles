-- https://neovide.dev/configuration.html
if vim.g.neovide then
  vim.g.neovide_cursor_vfx_mode = ""
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_position_animation_length = 0
  vim.g.neovide_scroll_animation_far_lines = 0
  vim.g.neovide_scroll_animation_length = 0

  -- allow pasting with cmd+v
  vim.keymap.set({ "n", "v", "s", "x", "o", "i", "l", "c", "t" }, "<D-v>", function()
    vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
  end, { noremap = true, silent = true })
end
