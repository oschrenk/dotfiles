-- Leader/local leader
vim.g.mapleader = [[ ]]
vim.g.maplocalleader = [[,]]

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugs", {
  defaults = {
    -- if "true" by default all plugins will be loaded lazily
    lazy = true,
    -- install specific versions of plugins.you can use
    -- "commit", "tag", "branch", or "version"
    -- "*" will install latest stable version of plugins that support Semver.
    -- "false" latest available version. recommended
    version = false,
  },
  checker = {
    -- automatically check for plugin updates
    enabled = false,
  },
  change_detection = {
    -- automatically check for config file changes and reload the ui
    enabled = false,
    -- get a notification when changes are found
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "editorconfig",
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "shada",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

require("options")
require("actions")
require("keymaps")
