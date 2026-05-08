-- cmp engine
-- https://github.com/Saghen/blink.cmp
return {
  "saghen/blink.cmp",
  build = function()
    require("blink.cmp").build():wait(60000)
  end,
  dependencies = {
    -- https://github.com/saghen/blink.lib
    -- required by blink.cmp v2
    "saghen/blink.lib",

    -- https://github.com/saghen/blink.compat
    "saghen/blink.compat",

    -- https://github.com/mgalliou/blink-cmp-tmux
    -- source for tmux
    "mgalliou/blink-cmp-tmux",

    -- https://github.com/Dynge/gitmoji.nvim
    -- source for gitmoji on :
    "Dynge/gitmoji.nvim",

    -- https://github.com/oschrenk/blink-cmp-browser
    -- source for browser (native blink.cmp source, port of cmp-browser-source)
    -- relies on Chrome extension
    -- https://chromewebstore.google.com/detail/completion-source-provide/dgfnehmpeggdlmbblgjfbfioegibajlb
    -- start_server() binds the WebSocket listener at nvim startup so the Chrome
    -- extension can push on page load before blink lazily instantiates the source.
    {
      "oschrenk/blink-cmp-browser",
      dir = "/Users/oliver/Projects/tools/blink-cmp-browser",
      config = function()
        require("blink-cmp-browser").start_server()
      end,
    },
  },

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    keymap = {
      preset = "enter",
    },
    completion = {
      documentation = {
        auto_show = true,
      },
    },
    -- Default list of enabled providers
    sources = {
      default = {
        "browser",
        "buffer",
        "gitmoji",
        "lsp",
        "path",
        "snippets",
        "tmux",
      },
      providers = {
        browser = {
          name = "browser",
          module = "blink-cmp-browser",
          transform_items = function(_, items)
            for _, item in ipairs(items) do
              item.kind_icon = ""
              if item.labelDetails then
                item.labelDetails.detail = nil
              end
            end
            return items
          end,
        },
        tmux = {
          name = "tmux",
          module = "blink-cmp-tmux",
          transform_items = function(_, items)
            for _, item in ipairs(items) do
              item.kind_icon = ""
              if item.labelDetails then
                item.labelDetails.detail = nil
              end
            end
            return items
          end,
        },
        gitmoji = {
          name = "gitmoji",
          module = "gitmoji.blink",
          opts = { -- gitmoji config values goes here
            completion = {
              append_space = true,
              complete_as = "text",
            },
            filetypes = { "gitcommit", "jj" },
          },
          transform_items = function(_, items)
            for _, item in ipairs(items) do
              item.kind_icon = ""
              if item.labelDetails then
                item.labelDetails.detail = nil
              end
            end
            return items
          end,
        },
      },
    },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    fuzzy = {
      implementation = "prefer_rust_with_warning",
    },
  },
  opts_extend = {
    "sources.default",
  },
}
