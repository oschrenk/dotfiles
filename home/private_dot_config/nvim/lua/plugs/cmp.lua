return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter" },
  dependencies = {
    "hrsh7th/cmp-buffer",
    'hrsh7th/cmp-nvim-lsp',
    'andersevenrud/cmp-tmux',
    'wxxxcxx/cmp-browser-source',
    'hrsh7th/cmp-vsnip',
    'hrsh7th/vim-vsnip'
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
        { name = 'buffer' },
        { name = 'tmux' },
        { name = 'browser' },
        { name = "nvim_lsp" }
      }
    })
  end
}
