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
    {
      "wxxxcxx/cmp-browser-source",
      config = function()
        -- starts server on default port 18998
        require("cmp-browser-source").start_server()
      end,
    },
    -- https://github.com/hrsh7th/cmp-vsnip
    -- source for snippet emgine
    "hrsh7th/cmp-vsnip",

    -- https://github.com/hrsh7th/vim-vsnip
    -- snippet engine
    -- cmp unfortunately REQUIRES a snippet engine
    -- otherwise I would not bring this in
    "hrsh7th/vim-vsnip",

    -- https://github.com/zbirenbaum/copilot-cmp
    -- source for Github completions
    {
      "zbirenbaum/copilot-cmp",
      dependencies = {
        { "zbirenbaum/copilot.lua", build = "Copilot auth" },
      },
      config = function()
        require("copilot_cmp").setup({})
        require("copilot").setup({
          panel = {
            enabled = false,
          },
          suggestion = {
            enabled = false,
          },
        })
      end,
    },

    -- https://github.com/onsails/lspkind.nvim
    -- make menu/icons prettier
    "onsails/lspkind.nvim",
  },
  config = function()
    vim.api.nvim_set_hl(0, "CmpItemKindBrowser", { fg = "#689d6a" })
    vim.api.nvim_set_hl(0, "CmpItemKindBuffer", { fg = "#b57614" })
    vim.api.nvim_set_hl(0, "CmpItemKindTmux", { fg = "#d79921" })
    vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#b8bb26" })

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
        { name = "copilot" },
        { name = "tmux" },
        { name = "browser" },
        { name = "nvim_lsp" },
      },
      formatting = {
        format = function(entry, vim_item)
          if entry.source.name == "browser" then
            vim_item.kind = "Browser "
            vim_item.menu = ""
            vim_item.kind_hl_group = "CmpItemKindBrowser"
          end
          if entry.source.name == "buffer" then
            vim_item.kind = "Buffer "
            vim_item.menu = ""
            vim_item.kind_hl_group = "CmpItemKindBuffer"
          end
          if entry.source.name == "tmux" then
            vim_item.kind = "Tmux "
            vim_item.menu = ""
            vim_item.kind_hl_group = "CmpItemKindTmux"
          end

          if entry.source.name == "copilot" then
            vim_item.kind = "Copilot "
            vim_item.menu = ""
            vim_item.kind_hl_group = "CmpItemKindCopilot"
          end
          -- format lsp entries using lspkind
          if entry.source.name == "nvim_lsp" then
            vim_item = require("lspkind").cmp_format({
              mode = "text_symbol",
              maxwidth = 50,
            })(entry, vim_item)
          end

          return vim_item
        end,
      },
    })
  end,
}
