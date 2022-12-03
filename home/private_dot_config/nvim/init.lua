require('impatient')

local o = vim.o
local g = vim.g
local cmd = vim.cmd
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local home = os.getenv("HOME")

-- Leader/local leader
g.mapleader = [[ ]]
g.maplocalleader = [[,]]

-- Skip some remote provider loading
g.loaded_python3_provider = 0
g.loaded_node_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
g.loaded_netrw         = 1

-- Disable some built-in plugins we don't want
local disabled_built_ins = {
  '2html_plugin',
  'getscript',
  'getscriptPlugin',
  'gzip',
  'man',
  'matchit',
  'matchparen',
  'netrw',
  'netrwFileHandlers',
  'netrwPlugin',
  'netrwSettings',
  'shada_plugin',
  'tar',
  'tarPlugin',
  'vimball',
  'vimballPlugin',
  'zip',
  'zipPlugin',
}
for i = 1, 10 do
  g['loaded_' .. disabled_built_ins[i]] = 1
end

-- ============================
-- Look and Feel
-- ============================
o.background = 'dark'
vim.cmd('colorscheme gruvbox')
vim.g['gruvbox_sign_column'] = 'bg0'

o.cursorcolumn = true   -- highlights column
o.cursorline = true     -- highlights line
o.laststatus = 0        -- hide statusbar
o.number= true          -- show line number
o.scrolloff = 1         -- ensure number of visible lines above/below cursor
o.sidescrolloff = 5     -- ensure number of visible columns left/right to cursor
o.signcolumn = "number" -- show sign in number column
o.termguicolors = true  -- emit 24-bit colours
o.title = true          -- show title in console title bar.

-- command bar
o.cmdheight = 2        -- the command bar is 2 high.
o.showmode = true      -- show current-mode
o.showcmd = true       -- show partially-typed commands

vim.opt.display = vim.opt.display:append('lastline') -- show as much as possible from last line

-- ============================
-- Config, Global
-- ============================
-- window management
o.splitright = true    -- always split to the right
o.splitbelow = true    -- always split to the bottom

-- behaviour
o.wildmenu = true      -- visual autocomplete for command menu
o.showmatch = true     -- show matching brackets

-- performance
o.updatetime = 300     -- bad experience for diagnostic messages when it's default 4000
o.lazyredraw = true    -- redraw only when required

-- indentation and whitespace
o.autoindent = true    -- copy indentation from last line
o.smartindent = true   -- automatically inserts one extra level in some cases
o.expandtab = true     -- <TAB> will insert 'softtabstop' spaces
o.tabstop = 2          -- width of the <TAB> character
o.shiftwidth = 2       -- affects >>, <<, ==
o.softtabstop = 2
o.backspace = 'indent,eol,start' -- make backspace work like most other app

-- searching
o.hlsearch = true        -- Highlight search matches
o.ignorecase = true      -- Ignore case when searching
o.inccommand = 'nosplit' -- nvim 0.6+ only.live preview for substitute command
o.incsearch = true       -- Highlight search matches as you type
o.smartcase = true       -- Ignore case if pattern lowercase, case-sensitive otherwise

-- external files
o.autoread = true        -- Set to auto read when a file is changed from the outside
o.clipboard = 'unnamed,unnamedplus' -- cross platform clipboard access

-- disable backups/swap files
o.backup = false
o.writebackup = false
o.swapfile = false

-- ===========================
-- Auto corrections
-- ===========================
vim.cmd('iab xtoday <c-r>=strftime("%Y%m%d")<cr>')
vim.cmd('iab xToday <c-r>=strftime("%Y-%m-%d")<cr>')
vim.cmd('iab xtime <c-r>=strftime("%H:%M")<cr>')
vim.cmd('iab xnow <c-r>=strftime("%Y%m%d %H:%M")<cr>')

vim.cmd('iab soem some')
vim.cmd('iab teh the')
vim.cmd('iab tommorow tomorrow')
vim.cmd('iab tommorrow tomorrow')

-- ===========================
-- Spellcheck
-- ===========================
o.spelllang = 'en'
o.spellfile = home .. '/.config/nvim/spell/en.utf-8.add' -- dictionary location


autocmd('FileType', { pattern = 'gitcommit', command = 'setlocal spell' })
autocmd('FileType', { pattern = 'markdown', command = 'setlocal spell' })

-- ===========================
-- Filetypes
-- ===========================
local my_filetypes = augroup("MyFiletypes", { clear = true })

-- make .md markdown files
autocmd('BufRead,BufNewFile', {
	  pattern = 'md',
	  command = 'set filetype=markdown',
	  group = my_filetypes
  })
-- make Jenkinsfile groovy
autocmd('BufRead,BufNewFile', {
	pattern = 'Jenkinsfile',
	command = 'set filetype=groovy',
	group = my_filetypes
})

-- ===========================
-- Actions
-- ===========================
local my_actions = augroup("MyActions", { clear = true })
-- Reload when entering buffer or gaining focus
-- costs ~280ms startup time
-- au FocusGained,BufEnter * :silent! !
--
-- Autosave on focus lost or when exiting the buffer
autocmd('FocusLost,WinLeave', {
  pattern = '*',
  command = ':silent! w',
  group = my_actions
})

-- Auto-Delete trailing whitspace
autocmd('BufWritePre,WinLeave', {
  pattern = '*',
  command = [[:%s/\s\+$//e]] ,
  group = my_actions
})

-- ===========================
-- Undo
-- ===========================
-- Keep undo history across sessions
-- :help undo-persistence
-- requires +undofile
-- if path ends in two slashes, file name will use complete path
-- :help dir
o.undodir= home .. "/.config/nvim/undo//"
o.undofile = true
o.undolevels=500
o.undoreload=500

-- ============================
-- Fern
-- ============================

vim.api.nvim_exec(
[[
let g:fern#disable_default_mappings   = 1
" let g:fern#disable_drawer_auto_quit   = 1
" let g:fern#disable_viewer_hide_cursor = 1
let g:fern#renderer = "nerdfont"

noremap <silent> - :Fern . -reveal=% -drawer -width=35 -toggle -right<CR><C-w>=

function! FernInit() abort
  nmap <buffer><expr>
        \ <Plug>(fern-my-open-expand-collapse)
        \ fern#smart#leaf(
        \   "\<Plug>(fern-action-open:select)",
        \   "\<Plug>(fern-action-expand)",
        \   "\<Plug>(fern-action-collapse)",
        \ )
  nmap <buffer> <CR> <Plug>(fern-my-open-expand-collapse)
  nmap <buffer> m <Plug>(fern-action-mark:toggle)j
  nmap <buffer> N <Plug>(fern-action-new-file)
  nmap <buffer> K <Plug>(fern-action-new-dir)
  nmap <buffer> D <Plug>(fern-action-remove)
  nmap <buffer> C <Plug>(fern-action-move)
  nmap <buffer> R <Plug>(fern-action-rename)
  nmap <buffer> r <Plug>(fern-action-reload)
  nmap <buffer> <nowait> d <Plug>(fern-action-hidden:toggle)
endfunction

augroup FernEvents
  autocmd!
  autocmd FileType fern call FernInit()
augroup END

augroup FernTypeGroup
    autocmd! * <buffer>
    autocmd BufEnter <buffer> silent execute "normal \<Plug>(fern-action-reload)"
augroup END

function! s:on_highlight() abort
  " Use brighter highlight on root node
  highlight link FernRootSymbol Title
  highlight link FernRootText   Title
endfunction

augroup my-fern-highlight
  autocmd!
  autocmd User FernHighlight call s:on_highlight()
augroup END
]],
false)

-- typescript,js, tsx not playing well
-- " autocmd BufEnter *.{ts} :syntax sync fromstart
-- " autocmd BufLeave *.{ts} :syntax sync clear
-- " autocmd BufEnter *.{js} :syntax sync fromstart
-- " autocmd BufLeave *.{js} :syntax sync clear
-- " autocmd BufEnter *.{jsx,tsx} :syntax sync fromstart
-- " autocmd BufLeave *.{jsx,tsx} :syntax sync clear


-- ============================
-- Keyboard mappings
-- ============================

vim.api.nvim_exec(
[[
" Do not enter Ex mode by accident
nnoremap Q <Nop>

" Disable arrow keys
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>
nnoremap <Left> <nop>
nnoremap <Right> <nop>
nnoremap <Up> <nop>
noremap <Down> <nop>

" move cursors naturally
nnoremap j gj
nnoremap k gk

" U: Redos since 'u' undos
nnoremap U :redo<cr>

" N: Find next occurrence backward
nnoremap N Nzzzv

" Use <C-c> to clear the highlighting of :set hlsearch.
if maparg('<C-c>', 'n') ==# ''
  nnoremap <silent> <C-c> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif
]],
false)


-- ============================
-- Plugins
-- ============================
require('plugins')

