-- bootstrap lazy plugin manager
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

-- Leader/local leader
vim.g.mapleader = [[ ]]
vim.g.maplocalleader = [[,]]

-- load plugins
require("lazy").setup("plugs", {
  defaults = {
    -- if "true" -> all plugins will be loaded lazily
    lazy = true,
    -- install specific versions of plugins:
    -- "commit", "tag", "branch", or "version"
    -- "*" installs latest stable version of plugins
    -- "false" latest available version. recommended
    version = false,
  },
  checker = {
    -- automatically check for plugin updates
    enabled = false,
  },
  change_detection = {
    -- auto-reload on config changes
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
