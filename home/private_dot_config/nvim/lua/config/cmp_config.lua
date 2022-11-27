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
