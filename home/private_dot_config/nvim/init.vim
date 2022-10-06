" ============================
" Plugins
" ============================

lua require('plugins')

lua << EOF
local o = vim.o

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

EOF

" Keep undo history across sessions
" :help undo-persistence
if exists("+undofile")
  " create dir if it doesn't exist
  if isdirectory($HOME . '/.config/nvim/undo') == 0
    :silent !mkdir -p ~/.config/nvim/undo > /dev/null 2>&1
  endif
  " if path ends in two slashes, file name will use complete path
  " :help dir
  set undodir=~/.config/nvim/undo//
  set undofile
  set undolevels=500
  set undoreload=500
endif

" change formatting behaviour
" I don't like vim autoinserting comments for me
" I would love to just use `set formatoptions-=ro` but since C file plugin is
" loaded after loading .vimrc, the behaviour is overwritten, so resorting to
" autocmd is necessary
" default is tcq
" r automatically insert comment leader after <enter> in INSERT
" o automatically insert comment leader after o or O in NORMAL
" -= removes these options
autocmd BufNewFile,BufRead * setlocal formatoptions-=ro

" Reload when entering buffer or gaining focus
au FocusGained,BufEnter * :silent! !

" Autosave on focus lost or when exiting the buffer
au FocusLost,WinLeave * :silent! w

" Auto-Delete trailing whitspace
autocmd BufWritePre *.* :%s/\s\+$//e

" Jump to last cursor position when opening a file
autocmd BufReadPost * call s:SetCursorPosition()
function! s:SetCursorPosition()
    if &filetype !~ 'svn\|commit\c'
        if line("'\"") > 0 && line("'\"") <= line("$")
            exe "normal! g`\""
            normal! zz
        endif
    end
endfunction

" Jump to first character or column
noremap <silent> H :call FirstCharOrFirstCol()<cr>
function! FirstCharOrFirstCol()
  let current_col = virtcol('.')
  normal ^
  let first_char = virtcol('.')
  if current_col == first_char
    normal 0
  endif
endfunction

" ----------------------
" Filetypes
" ----------------------
" make .md markdown files
au BufRead,BufNewFile *.md set filetype=markdown

" make Jenkinsfile groovy
autocmd BufRead,BufNewFile Jenkinsfile set filetype=groovy

au FileType gitcommit :call AutoBranch()

" when commiting add [BRANCH] (if matching prefix), and enter insert mode
function! AutoBranch()
  " don't do anything when amending
  if getline(1) == ""
    let branch = trim(system('git branch --show-current 2>/dev/null'))
    let ticket_match = matchstr(branch, '\v^[0-9]+')
    " only add prefix when branch name matches
    if ticket_match != ""
      call append(0, "GH-" . ticket_match . " ")
      execute "norm k"
    endif
    " start in insert mode
    startinsert!
  end
endfunction

" ============================
" Plugin configuration
" ============================

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
  nmap <buffer> <2-LeftMouse> <Plug>(fern-my-open-expand-collapse)
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

autocmd BufEnter *.{ts} :syntax sync fromstart
autocmd BufLeave *.{ts} :syntax sync clear
autocmd BufEnter *.{js} :syntax sync fromstart
autocmd BufLeave *.{js} :syntax sync clear
autocmd BufEnter *.{jsx,tsx} :syntax sync fromstart
autocmd BufLeave *.{jsx,tsx} :syntax sync clear

" ============================
" Keyboard mappings
" ============================

" map leader to <space>
let mapleader = "\<space>"

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

" quickly move to end of line
nnoremap L $

" U: Redos since 'u' undos
nnoremap U :redo<cr>

" N: Find next occurrence backward
nnoremap N Nzzzv

" Use <C-c> to clear the highlighting of :set hlsearch.
if maparg('<C-c>', 'n') ==# ''
  nnoremap <silent> <C-c> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif


" ===========================
" Spellcheck
" ===========================
set spelllang=en
set spellfile=$HOME/.config/nvim/spell/en.utf-8.add " spellcheck dictionary location
set complete+=kspell                        " word comletion via ctrl n/p
autocmd FileType gitcommit setlocal spell   " spellcheck git commit messages
autocmd FileType markdown  setlocal spell   " spelllcheck markdown filetypes

" ===========================
" Auto corrections
" ===========================

iab xtoday <c-r>=strftime("%Y%m%d")<cr>
iab xToday <c-r>=strftime("%Y-%m-%d")<cr>
iab xtime <c-r>=strftime("%H:%M")<cr>
iab xnow <c-r>=strftime("%Y%m%d %H:%M")<cr>

iab soem some
iab teh the
iab tommorow tomorrow
iab tommorrow tomorrow


nnoremap <leader>ff <cmd>Telescope find_files<cr>

lua << EOF
require('telescope').setup{
	defaults = {
    layout_strategy = "flex",
    layout_config = {
      vertical = {
        preview_cutoff = 20,
      },
      horizontal = {
        preview_cutoff = 80,
      },
    },
		path_display={"smart"},
    file_previewer = require'telescope.previewers'.vim_buffer_cat.new
	}
}
require('telescope').load_extension('fzf')
EOF

lua << EOF
require('gitsigns').setup{
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    -- Actions
    map({'n', 'v'}, '<space>hs', ':Gitsigns stage_hunk<CR>')
    map({'n', 'v'}, '<space>hu', ':Gitsigns reset_hunk<CR>')

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}

EOF

lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "bash", "fish",
    "html", "css",
    "lua", "vim",
    "python",
    "scala", "hocon",
    "markdown",
    "javascript", "json", "typescript", "tsx",
    "hcl"
  },
  highlight = {
    enable = true,
    -- can be boolean or list of languages
    additional_vim_regex_highlighting = false,
  },
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = nil,
  }
}
EOF

lua <<EOF

  local cmp = require'cmp'

  cmp.setup({
    -- required to be able to select item via return key
    -- annoying to bring in just another plugin for that, but alas
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      -- `select = true` not allowed _unless_ snippet section also configured
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      -- use tab
      ["<Tab>"] = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end,
      ["<S-Tab>"] = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end,
    }),
    sources = {
      { name = 'buffer' },
      { name = 'tmux' },
      { name = 'browser' },
      { name = "nvim_lsp" }
    }
  })

  require('cmp-browser-source').start_server()
EOF

lua <<EOF
local metals_config = require("metals").bare_config()

metals_config.settings = {
  showImplicitArguments = true,
  excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
}
metals_config.init_options.statusBarProvider = "on"

local capabilities = vim.lsp.protocol.make_client_capabilities()
metals_config.capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

vim.cmd([[autocmd FileType scala,sbt lua require("metals").initialize_or_attach({})]])

EOF
