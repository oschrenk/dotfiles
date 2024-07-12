-- https://neovide.dev/configuration.html
if vim.g.neovide then
  vim.g.neovide_position_animation_length = 0
  -- When scrolling more than one screen at a time, only this many lines at the end of the scroll action will be animated. Set it to 0 to snap to the final position without any animation, or to something big like 9999 to always scroll the whole screen, much like Neovide <= 0.10.4 did.
  vim.g.neovide_scroll_animation_far_lines = 0
  vim.g.neovide_scroll_animation_length = 0

  -- Cursor Particles
  -- https://neovide.dev/configuration.html#cursor-particles
  --
  -- "" (= no vfx) default
  -- "railgun"
  -- "torpedo"
  -- "pixiedust"
  -- "sonicboom"
  -- "ripple"
  -- "wireframe"
  vim.g.neovide_cursor_vfx_mode = ""
  --vim.g.neovide_cursor_vfx_opacity = 200.0
  --vim.g.neovide_cursor_vfx_particle_lifetime = 1.2
  --vim.g.neovide_cursor_vfx_particle_speed = 10.0
  --vim.g.neovide_cursor_vfx_particle_density = 7.0
  --vim.g.neovide_cursor_vfx_particle_phase = 1.5 -- railgun only
  --vim.g.neovide_cursor_vfx_particle_curl = 1.0 -- railgun only
end
