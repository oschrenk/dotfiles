-- https://github.com/hrsh7th/nvim-cmp
-- completion engine plugin
--
return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter" },
  dependencies = {
    -- https://github.com/hrsh7th/cmp-buffer
    -- source for words in buffer
    "hrsh7th/cmp-buffer",

    -- https://github.com/hrsh7th/cmp-nvim-lsp
    -- source for lsp
    "andersevenrud/cmp-tmux",

    -- https://github.com/andersevenrud/cmp-tmux
    -- source for tmux
    "hrsh7th/cmp-nvim-lsp",

    -- https://github.com/wxxxcxx/cmp-browser-source
    -- source for browser
    -- relies on Chrome extension
    -- https://chromewebstore.google.com/detail/completion-source-provide/dgfnehmpeggdlmbblgjfbfioegibajlb
    "wxxxcxx/cmp-browser-source",

    -- https://github.com/hrsh7th/cmp-vsnip
    -- source for snippet emgine
    "hrsh7th/cmp-vsnip",

    -- https://github.com/hrsh7th/vim-vsnip
    -- snippet engine
    -- cmp unfortunately REQUIRES a snippet engine
    -- otherwise I would not bring this in
    "hrsh7th/vim-vsnip",
  },
  config = function()
    require("cmp").setup({
      -- required to be able to select item via return key
      -- annoying to bring in just another plugin for that, but alas
      snippet = {
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body)
        end,
      },
      mapping = require("cmp").mapping.preset.insert({
        -- `select = true` not allowed _unless_ snippet section also configured
        ["<CR>"] = require("cmp").mapping.confirm({ select = true }),
        -- use tab
        ["<Tab>"] = function(fallback)
          if require("cmp").visible() then
            require("cmp").select_next_item()
          else
            fallback()
          end
        end,
        ["<S-Tab>"] = function(fallback)
          if require("cmp").visible() then
            require("cmp").select_prev_item()
          else
            fallback()
          end
        end,
      }),
      sources = {
        { name = "buffer" },
        { name = "tmux" },
        { name = "browser" },
        { name = "nvim_lsp" },
      },
      formatting = {
        format = function(entry, vim_item)
          vim_item.menu = ({
            buffer = "",
            tmux = "",
            browser = "",
            nvim_lsp = "",
            vim_dadbod_completion = "",
          })[entry.source.name:gsub("-", "_")]
          return vim_item
        end,
      },
    })
    -- starts server on default port 18998
    require("cmp-browser-source").start_server()
  end,
}
