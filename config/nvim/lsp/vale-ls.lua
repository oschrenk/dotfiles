-- prose
-- https://vale.sh
-- Config lives in nix/modules/home/vale.nix, deployed to
-- ~/.config/vale/.vale.ini. Styles are synced there at nix activation.

-- Vale only looks in ~/.config when XDG_CONFIG_HOME is set. A shell-launched
-- nvim inherits it from fish, but neovide started from the Dock does not, and
-- vale-ls then reports nothing at all rather than failing. Setting it here
-- costs nothing when it is already set.
vim.env.XDG_CONFIG_HOME = vim.env.XDG_CONFIG_HOME or vim.fn.expand("~/.config")

return {
  cmd = { "vale-ls" },
  root_markers = { ".vale.ini", "_vale.ini", ".git" },
  filetypes = {
    "markdown",
    "gitcommit",
  },
  init_options = {
    -- vale comes from nix, so the server must never fetch its own copy.
    installVale = false,
    -- Styles are synced by the valeSync activation script, not on every
    -- server start.
    syncOnStartup = false,
    lintOnChange = true,
  },
}
