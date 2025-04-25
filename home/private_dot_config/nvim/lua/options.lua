local o = vim.o
local g = vim.g
local home = os.getenv("HOME")

-- Skip some remote provider loading
g.loaded_python3_provider = 0
g.loaded_node_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
g.loaded_netrw = 1

-- Disable some built-in plugins we don't want
local disabled_built_ins = {
  "2html_plugin",
  "getscript",
  "getscriptPlugin",
  "gzip",
  "man",
  "matchit",
  "matchparen",
  "netrw",
  "netrwFileHandlers",
  "netrwPlugin",
  "netrwSettings",
  "shada_plugin",
  "tar",
  "tarPlugin",
  "vimball",
  "vimballPlugin",
  "zip",
  "zipPlugin",
}

for i = 1, 18 do
  g["loaded_" .. disabled_built_ins[i]] = 1
end
-- ============================
-- Look and Feel
-- ============================

o.cursorcolumn = true -- highlights column
o.cursorline = true -- highlights line
o.laststatus = 0 -- hide statusbar
o.number = true -- show line number
o.scrolloff = 1 -- ensure number of visible lines above/below cursor
o.sidescrolloff = 5 -- ensure number of visible columns left/right to cursor
o.signcolumn = "number" -- show sign in number column
o.termguicolors = true -- emit 24-bit colours
o.title = true -- show title in console title bar.

-- command bar
o.cmdheight = 0 -- height of command bar, 0 just looks good
o.showmode = true -- show current-mode
o.showcmd = true -- show partially-typed commands

vim.opt.display = vim.opt.display:append("lastline") -- show as much as possible from last line

-- ============================
-- Config, Global
-- ============================
-- window management
o.splitright = true -- always split to the right
o.splitbelow = true -- always split to the bottom

-- behaviour
o.wildmenu = true -- visual autocomplete for command menu
o.showmatch = true -- show matching brackets

-- performance
o.updatetime = 300 -- bad experience for diagnostic messages when it's default 4000
o.lazyredraw = true -- redraw only when required

-- indentation and whitespace
o.autoindent = true -- copy indentation from last line
o.smartindent = true -- automatically inserts one extra level in some cases
o.expandtab = true -- <TAB> will insert 'softtabstop' spaces
o.tabstop = 2 -- width of the <TAB> character
o.shiftwidth = 2 -- affects >>, <<, ==
o.softtabstop = 2
o.backspace = "indent,eol,start" -- make backspace work like most other app

-- searching
o.hlsearch = true -- Highlight search matches
o.ignorecase = true -- Ignore case when searching
o.inccommand = "nosplit" -- nvim 0.6+ only.live preview for substitute command
o.incsearch = true -- Highlight search matches as you type
o.smartcase = true -- Ignore case if pattern lowercase, case-sensitive otherwise

-- external files
o.autoread = true -- Set to auto read when a file is changed from the outside
o.clipboard = "unnamed,unnamedplus" -- cross platform clipboard access

-- disable backups/swap files
o.backup = false
o.writebackup = false
o.swapfile = false

-- ===========================
-- Undo
-- ===========================
-- Keep undo history across sessions
-- :help undo-persistence
-- requires +undofile
-- if path ends in two slashes, file name will use complete path
-- :help dir
o.undodir = home .. "/.config/nvim/undo//"
o.undofile = true
o.undolevels = 500
o.undoreload = 500

-- ===========================
-- Spellcheck
-- ===========================
o.spelllang = "en"
o.spellfile = home .. "/.config/nvim/spell/en.utf-8.add" -- dictionary location
