return {
  "goolord/alpha-nvim",
  -- load plugin after all configuration is set
  event = "VimEnter",
  dependencies = {},
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    local header = {
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                     ]],
      [[       ████ ██████           █████      ██                     ]],
      [[      ███████████             █████                             ]],
      [[      █████████ ███████████████████ ███   ███████████   ]],
      [[     █████████  ███    █████████████ █████ ██████████████   ]],
      [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
      [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
      [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                       ]],
    }

    dashboard.section.header.val = header

    dashboard.section.buttons.val = {
      dashboard.button("e", "   File explorer", ":Oil <CR>"),
      dashboard.button("f", "   Find file", ":Telescope find_files previewer=false<CR>"),
      dashboard.button("w", "󰱼   Find word", ":Telescope live_grep<CR>"),
      dashboard.button("r", "   Recent", ":Telescope oldfiles<CR>"),
      dashboard.button("c", "   Config", ":e $MYVIMRC <CR>"),
      dashboard.button("q", "   Quit NVIM", ":qa<CR>"),
    }

    -- set highlight groups
    -- setting to none to get default fg
    dashboard.section.header.opts.hl = ""
    for _, button in ipairs(dashboard.section.buttons.val) do
      button.opts.hl_shortcut = ""
      button.opts.hl = ""
    end

    -- This prevents any unwanted autocommands (e.g., BufRead, BufEnter)
    dashboard.opts.opts.noautocmd = true

    alpha.setup(dashboard.opts)
  end,
}
